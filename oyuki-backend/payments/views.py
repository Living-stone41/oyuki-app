from django.shortcuts import render
from django.db import transaction
from django.utils import timezone
from rest_framework import status, generics
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema

from common.responses import success_response
from accounts.permissions import IsAdmin, IsAccountOfficer
from orders.models import Order, OrderStatus
from .models import Payment, PaymentStatus, PaymentAuditLog
from .serializers import PaymentSerializer, InitiatePaymentSerializer, ReviewPaymentSerializer


class InitiatePaymentView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=InitiatePaymentSerializer)
    def post(self, request):
        serializer = InitiatePaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        order = Order.objects.filter(
            pk=serializer.validated_data["order_id"], customer=request.user
        ).first()
        if not order:
            return success_response(message="Order not found.", status_code=404)
        if order.status in (OrderStatus.REJECTED, OrderStatus.CANCELLED):
            return success_response(message=f"Order is {order.status}; payment not allowed.", status_code=400)
        if order.payments.filter(status__in=[PaymentStatus.PENDING, PaymentStatus.CONFIRMED]).exists():
            return success_response(message="This order already has a pending or confirmed payment.",
                                     status_code=400)

        with transaction.atomic():
            payment = Payment.objects.create(
                order=order,
                customer=request.user,
                method=serializer.validated_data["method"],
                amount=order.total,  # always from the order, never from the request
            )
            PaymentAuditLog.objects.create(
                payment=payment, from_status="", to_status=PaymentStatus.PENDING,
                changed_by=request.user, note="Payment initiated.",
            )

        return success_response(data=PaymentSerializer(payment).data,
                                 message="Payment initiated.",
                                 status_code=status.HTTP_201_CREATED)


class MyPaymentsView(generics.ListAPIView):
    serializer_class = PaymentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Payment.objects.filter(customer=self.request.user).order_by("-created_at")


class AdminPaymentsView(generics.ListAPIView):
    serializer_class = PaymentSerializer
    permission_classes = [IsAdmin | IsAccountOfficer]

    def get_queryset(self):
        qs = Payment.objects.all().order_by("-created_at")
        status_filter = self.request.query_params.get("status")
        if status_filter:
            qs = qs.filter(status=status_filter)
        return qs


class ReviewPaymentView(APIView):
    permission_classes = [IsAdmin | IsAccountOfficer]

    @extend_schema(request=ReviewPaymentSerializer)
    def post(self, request, pk):
        payment = Payment.objects.filter(pk=pk).first()
        if not payment:
            return success_response(message="Payment not found.", status_code=404)
        if payment.status != PaymentStatus.PENDING:
            return success_response(message=f"Payment already {payment.status}.", status_code=400)

        serializer = ReviewPaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        action = serializer.validated_data["action"]
        note = serializer.validated_data.get("note", "")

        old_status = payment.status
        with transaction.atomic():
            if action == "CONFIRM":
                payment.status = PaymentStatus.CONFIRMED
                payment.confirmed_by = request.user
                payment.confirmed_at = timezone.now()
            else:
                payment.status = PaymentStatus.FAILED
            payment.save()

            PaymentAuditLog.objects.create(
                payment=payment, from_status=old_status, to_status=payment.status,
                changed_by=request.user, note=note or f"Marked {payment.status}.",
            )

        return success_response(data=PaymentSerializer(payment).data)