from django.contrib.auth import get_user_model
from accounts.models import AccountStatus

User = get_user_model()


def create_user(role, username=None, email=None, password="TestPass123!", **extra):
    username = username or f"test_{role.lower()}"
    email = email or f"{role.lower()}@example.com"
    user = User(username=username, email=email, role=role, status=AccountStatus.ACTIVE, **extra)
    user.set_password(password)
    user.save()
    return user