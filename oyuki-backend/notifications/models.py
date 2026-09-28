from django.db import models
from django.db import models
from django.conf import settings
from common.models import TimeStampedModel


class NotificationType(models.TextChoices):
    ORDER = "ORDER", "Order"
    PAYMENT = "PAYMENT", "Payment"
    GENERAL = "GENERAL", "General"


class DevicePlatform(models.TextChoices):
    ANDROID = "ANDROID", "Android"
    IOS = "IOS", "iOS"


class Notification(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="notifications")
    notification_type = models.CharField(max_length=10, choices=NotificationType.choices,
                                          default=NotificationType.GENERAL)
    title = models.CharField(max_length=150)
    message = models.TextField()
    related_entity_type = models.CharField(max_length=20, blank=True)  # e.g. "order", "payment"
    related_entity_id = models.PositiveIntegerField(null=True, blank=True)
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [models.Index(fields=["user", "is_read"])]

    def __str__(self):
        return f"{self.title} -> {self.user}"


class DeviceToken(TimeStampedModel):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="device_tokens")
    token = models.CharField(max_length=255, unique=True)
    platform = models.CharField(max_length=10, choices=DevicePlatform.choices)