import uuid
from django.db import models
from django.conf import settings
from common.models import TimeStampedModel
from orders.models import Order


def generate_reference():
    return "OYK-" + uuid.uuid4().hex[:12].upper()


class PaymentMethod(models.TextChoices):
    BANK_TRANSFER = "BANK_TRANSFER", "Bank Transfer"
    # PAYSTACK will be added here later


class PaymentStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    CONFIRMED = "CONFIRMED", "Confirmed"
    FAILED = "FAILED", "Failed"
    CANCELLED = "CANCELLED", "Cancelled"
    REFUNDED = "REFUNDED", "Refunded"


class Payment(TimeStampedModel):
    order = models.ForeignKey(Order, on_delete=models.PROTECT, related_name="payments")
    customer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="payments")
    reference = models.CharField(max_length=32, unique=True, default=generate_reference)
    method = models.CharField(max_length=20, choices=PaymentMethod.choices)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=12, choices=PaymentStatus.choices, default=PaymentStatus.PENDING)
    confirmed_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
                                      null=True, blank=True, related_name="confirmed_payments")
    confirmed_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.reference} ({self.status})"


class PaymentAuditLog(models.Model):
    payment = models.ForeignKey(Payment, on_delete=models.CASCADE, related_name="audit_logs")
    from_status = models.CharField(max_length=12, blank=True)
    to_status = models.CharField(max_length=12)
    changed_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    note = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)