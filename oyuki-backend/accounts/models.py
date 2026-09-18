from django.contrib.auth.models import AbstractUser
from django.db import models


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