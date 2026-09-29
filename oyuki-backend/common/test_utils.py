from django.contrib.auth import get_user_model
from accounts.models import AccountStatus
from django.urls import reverse
from io import BytesIO
from PIL import Image
from django.core.files.uploadedfile import SimpleUploadedFile

User = get_user_model()

def make_test_image(name="test.jpg"):
    buffer = BytesIO()
    Image.new("RGB", (1, 1)).save(buffer, format="JPEG")
    buffer.seek(0)
    return SimpleUploadedFile(name, buffer.read(), content_type="image/jpeg")

def create_user(role, username=None, email=None, password="TestPass123!", **extra):
    username = username or f"test_{role.lower()}"
    email = email or f"{role.lower()}@example.com"
    user = User(username=username, email=email, role=role, status=AccountStatus.ACTIVE, **extra)
    user.set_password(password)
    user.save()
    return user
def login(client, username, password="TestPass123!"):
    response = client.post(reverse("login"), {"username": username, "password": password}, format="json")
    token = response.data["data"]["access"]
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")