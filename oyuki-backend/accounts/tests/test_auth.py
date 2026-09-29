from datetime import timedelta
from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase

from accounts.models import OTP, AccountStatus, Role
from accounts.utils import create_otp
from common.test_utils import create_user

User = get_user_model()


def make_pending_user(username="pendinguser", email="pending@example.com", password="StrongPass123!"):
    user = User(username=username, email=email, role=Role.CUSTOMER, status=AccountStatus.PENDING)
    user.set_password(password)
    user.save()
    return user


class RegistrationTests(APITestCase):
    def test_register_creates_pending_user_and_otp(self):
        payload = {"username": "newcustomer", "email": "newcustomer@example.com",
                   "password": "StrongPass123!", "role": "CUSTOMER"}
        response = self.client.post(reverse("register"), payload, format="json")

        self.assertEqual(response.status_code, 201)
        user = User.objects.get(username="newcustomer")
        self.assertEqual(user.status, AccountStatus.PENDING)
        self.assertTrue(OTP.objects.filter(user=user, purpose="VERIFY_EMAIL").exists())

    def test_duplicate_username_rejected(self):
        payload = {"username": "dupeuser", "email": "dupe1@example.com",
                   "password": "StrongPass123!", "role": "CUSTOMER"}
        self.client.post(reverse("register"), payload, format="json")
        payload["email"] = "dupe2@example.com"
        response = self.client.post(reverse("register"), payload, format="json")
        self.assertEqual(response.status_code, 400)


class VerifyOTPTests(APITestCase):
    def test_correct_code_activates_and_returns_tokens(self):
        user = make_pending_user()
        code = create_otp(user, purpose="VERIFY_EMAIL")

        response = self.client.post(reverse("verify-otp"), {"user_id": user.id, "code": code}, format="json")

        self.assertEqual(response.status_code, 200)
        self.assertIn("access", response.data["data"])
        user.refresh_from_db()
        self.assertEqual(user.status, AccountStatus.ACTIVE)

    def test_wrong_code_rejected(self):
        user = make_pending_user()
        create_otp(user, purpose="VERIFY_EMAIL")

        response = self.client.post(reverse("verify-otp"), {"user_id": user.id, "code": "000000"}, format="json")
        self.assertEqual(response.status_code, 400)
        user.refresh_from_db()
        self.assertEqual(user.status, AccountStatus.PENDING)

    def test_otp_locks_after_five_wrong_attempts(self):
        user = make_pending_user()
        create_otp(user, purpose="VERIFY_EMAIL")

        for _ in range(5):
            self.client.post(reverse("verify-otp"), {"user_id": user.id, "code": "000000"}, format="json")

        response = self.client.post(reverse("verify-otp"), {"user_id": user.id, "code": "000000"}, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertIn("Too many attempts", response.data["message"])

    def test_expired_otp_rejected(self):
        user = make_pending_user()
        code = create_otp(user, purpose="VERIFY_EMAIL")
        otp = OTP.objects.get(user=user)
        otp.expires_at = timezone.now() - timedelta(minutes=1)
        otp.save(update_fields=["expires_at"])

        response = self.client.post(reverse("verify-otp"), {"user_id": user.id, "code": code}, format="json")
        self.assertEqual(response.status_code, 400)


class LoginTests(APITestCase):
    def test_login_success_for_active_user(self):
        create_user(Role.CUSTOMER, username="activeuser", email="active@example.com", password="StrongPass123!")
        response = self.client.post(reverse("login"),
                                     {"username": "activeuser", "password": "StrongPass123!"}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertIn("access", response.data["data"])

    def test_login_blocked_for_pending_account(self):
        make_pending_user(username="pendinglogin", email="pendinglogin@example.com")
        response = self.client.post(reverse("login"),
                                     {"username": "pendinglogin", "password": "StrongPass123!"}, format="json")
        self.assertEqual(response.status_code, 403)

    def test_login_wrong_password_rejected(self):
        create_user(Role.CUSTOMER, username="wrongpass", email="wrongpass@example.com", password="StrongPass123!")
        response = self.client.post(reverse("login"),
                                     {"username": "wrongpass", "password": "Nope123!"}, format="json")
        self.assertEqual(response.status_code, 401)


class PasswordResetTests(APITestCase):
    def test_forgot_password_does_not_reveal_whether_email_exists(self):
        create_user(Role.CUSTOMER, username="active2", email="active2@example.com")
        known = self.client.post(reverse("forgot-password"), {"email": "active2@example.com"}, format="json")
        unknown = self.client.post(reverse("forgot-password"), {"email": "nobody@example.com"}, format="json")
        self.assertEqual(known.status_code, unknown.status_code)
        self.assertEqual(known.data["message"], unknown.data["message"])

    def test_reset_password_with_valid_otp(self):
        user = create_user(Role.CUSTOMER, username="resetme", email="resetme@example.com", password="OldPass123!")
        code = create_otp(user, purpose="RESET_PASSWORD")

        response = self.client.post(reverse("reset-password"), {
            "email": "resetme@example.com", "code": code, "new_password": "NewPass123!",
        }, format="json")
        self.assertEqual(response.status_code, 200)

        login = self.client.post(reverse("login"), {"username": "resetme", "password": "NewPass123!"}, format="json")
        self.assertEqual(login.status_code, 200)