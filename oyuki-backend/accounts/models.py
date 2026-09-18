from django.contrib.auth.models import AbstractUser
from django.db import models
import random
from django.utils import timezone
from datetime import timedelta

class Role(models.TextChoices):
    CUSTOMER = "CUSTOMER", "Customer"
    SELLER = "SELLER", "Seller/Farmer"
    ADMIN = "ADMIN", "Admin"
    ACCOUNT_OFFICER = "ACCOUNT_OFFICER", "Account Officer"
    LOGISTICS_ADMIN = "LOGISTICS_ADMIN", "Logistics Admin"
    RIDER = "RIDER", "Rider"
    MARKET_AGENT = "MARKET_AGENT", "Market Agent"
    MARKET_SUPERVISOR = "MARKET_SUPERVISOR", "Market Supervisor"
    MARKETER = "MARKETER", "Marketer"


class AccountStatus(models.TextChoices):
    ACTIVE = "ACTIVE", "Active"
    PENDING = "PENDING", "Pending Activation"
    DISABLED = "DISABLED", "Disabled"
    SUSPENDED = "SUSPENDED", "Suspended"


class User(AbstractUser):
    role = models.CharField(max_length=32, choices=Role.choices)
    status = models.CharField(max_length=16, choices=AccountStatus.choices, default=AccountStatus.PENDING)
    phone = models.CharField(max_length=20, blank=True, null=True, unique=True)

    def __str__(self):
        return f"{self.username} ({self.role})"


class OTP(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="otps")
    code_hash = models.CharField(max_length=128)
    purpose = models.CharField(max_length=32)  # e.g. "VERIFY_EMAIL", "RESET_PASSWORD"
    attempts = models.PositiveSmallIntegerField(default=0)
    expires_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    def is_expired(self):
        return timezone.now() > self.expires_at

    @staticmethod
    def generate_code():
        return f"{random.randint(0, 999999):06d}"