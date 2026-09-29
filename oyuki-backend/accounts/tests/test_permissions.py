from django.urls import reverse
from rest_framework.test import APITestCase

from accounts.models import Role
from common.test_utils import create_user


class AdminPingPermissionTests(APITestCase):
    def setUp(self):
        self.url = reverse("admin-ping")

    def authenticate_as(self, role, username):
        user = create_user(role, username=username, email=f"{username}@example.com")
        response = self.client.post(reverse("login"), {"username": username, "password": "TestPass123!"},
                                     format="json")
        token = response.data["data"]["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        return user

    def test_admin_can_access(self):
        self.authenticate_as(Role.ADMIN, "adminuser")
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)

    def test_customer_cannot_access(self):
        self.authenticate_as(Role.CUSTOMER, "customeruser")
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 403)

    def test_seller_cannot_access(self):
        self.authenticate_as(Role.SELLER, "selleruser")
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 403)

    def test_rider_cannot_access(self):
        self.authenticate_as(Role.RIDER, "rideruser")
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 403)

    def test_unauthenticated_cannot_access(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 401)


class MeEndpointTests(APITestCase):
    def test_returns_own_profile_when_authenticated(self):
        create_user(Role.CUSTOMER, username="meuser", email="meuser@example.com")
        login = self.client.post(reverse("login"), {"username": "meuser", "password": "TestPass123!"},
                                  format="json")
        token = login.data["data"]["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        response = self.client.get(reverse("me"))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"]["username"], "meuser")

    def test_requires_authentication(self):
        response = self.client.get(reverse("me"))
        self.assertEqual(response.status_code, 401)