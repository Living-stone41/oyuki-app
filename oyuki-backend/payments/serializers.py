from rest_framework import serializers
from .models import Payment, PaymentAuditLog, PaymentMethod


class PaymentAuditLogSerializer(serializers.ModelSerializer):
    changed_by_name = serializers.CharField(source="changed_by.username", read_only=True)

    class Meta:
        model = PaymentAuditLog
        fields = ["id", "from_status", "to_status", "changed_by_name", "note", "created_at"]


class PaymentSerializer(serializers.ModelSerializer):
    audit_log = PaymentAuditLogSerializer(source="audit_logs", many=True, read_only=True)

    class Meta:
        model = Payment
        fields = ["id", "order", "reference", "method", "amount", "status",
                  "confirmed_at", "audit_log", "created_at","proof_of_payment"]
        read_only_fields = fields


class InitiatePaymentSerializer(serializers.Serializer):
    order_id = serializers.IntegerField()
    method = serializers.ChoiceField(choices=PaymentMethod.choices)


class ReviewPaymentSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=["CONFIRM", "FAIL"])
    note = serializers.CharField(required=False, allow_blank=True)

class ProofOfPaymentUploadSerializer(serializers.Serializer):
    proof = serializers.ImageField()