from decimal import Decimal
from django.db import transaction
from django.contrib.auth import get_user_model
from rest_framework import status, generics
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema

from common.responses import success_response
from cart.models import Cart
from accounts.models import Role
from accounts.permissions import IsSeller, IsAdmin, IsLogisticsAdmin, IsRider
from .models import Order, OrderItem, OrderStatusHistory, OrderStatus
from .serializers import (
    OrderSerializer, CheckoutSerializer, SellerOrderActionSerializer,
    AssignRiderSerializer, RiderStatusUpdateSerializer,
)

User = get_user_model()


class CheckoutView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=CheckoutSerializer)
    def post(self, request):
        serializer = CheckoutSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        address = serializer.validated_data["delivery_address"]

        cart = Cart.objects.filter(customer=request.user).first()
        if not cart or not cart.items.exists():
            return success_response(message="Cart is empty.", status_code=400)

        items_by_seller = {}
        for item in cart.items.select_related("product", "product__seller"):
            if item.quantity > item.product.quantity_available:
                return success_response(
                    message=f"'{item.product.name}' only has {item.product.quantity_available} left.",
                    status_code=400,
                )
            items_by_seller.setdefault(item.product.seller_id, []).append(item)

        created_orders = []

        with transaction.atomic():
            for seller_id, items in items_by_seller.items():
                subtotal = sum(item.product.price * item.quantity for item in items)
                delivery_fee = Decimal("0.00")  # TODO: real delivery fee logic later
                total = subtotal + delivery_fee

                order = Order.objects.create(
                    customer=request.user,
                    seller_id=seller_id,
                    delivery_address=address,
                    subtotal=subtotal,
                    delivery_fee=delivery_fee,
                    total=total,
                )

                for item in items:
                    OrderItem.objects.create(
                        order=order,
                        product=item.product,
                        product_name=item.product.name,
                        unit_price=item.product.price,
                        quantity=item.quantity,
                        line_total=item.product.price * item.quantity,
                    )
                    item.product.quantity_available -= item.quantity
                    item.product.save(update_fields=["quantity_available"])

                OrderStatusHistory.objects.create(
                    order=order, status=OrderStatus.PENDING,
                    changed_by=request.user, note="Order placed.",
                )
                created_orders.append(order)

            cart.items.all().delete()

        return success_response(
            data=OrderSerializer(created_orders, many=True).data,
            message="Checkout successful.",
            status_code=status.HTTP_201_CREATED,
        )


class MyOrdersView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(customer=self.request.user).order_by("-created_at")


class MyOrderDetailView(generics.RetrieveAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(customer=self.request.user)


class SellerOrdersView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsSeller]

    def get_queryset(self):
        return Order.objects.filter(seller=self.request.user).order_by("-created_at")


class SellerOrderActionView(APIView):
    permission_classes = [IsSeller]

    @extend_schema(request=SellerOrderActionSerializer)
    def post(self, request, pk):
        order = Order.objects.filter(pk=pk, seller=request.user).first()
        if not order:
            return success_response(message="Order not found.", status_code=404)
        if order.status != OrderStatus.PENDING:
            return success_response(message=f"Order already {order.status}.", status_code=400)

        serializer = SellerOrderActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        action = serializer.validated_data["action"]

        if action == "ACCEPT":
            order.status = OrderStatus.ACCEPTED
            note = "Accepted by seller."
        else:
            order.status = OrderStatus.REJECTED
            order.reject_reason = serializer.validated_data.get("reject_reason", "")
            note = f"Rejected by seller: {order.reject_reason}"
            for item in order.items.all():
                item.product.quantity_available += item.quantity
                item.product.save(update_fields=["quantity_available"])

        order.save()
        OrderStatusHistory.objects.create(order=order, status=order.status,
                                           changed_by=request.user, note=note)
        return success_response(data=OrderSerializer(order).data)


class AdminOrdersView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAdmin]
    queryset = Order.objects.all().order_by("-created_at")


class AssignRiderView(APIView):
    permission_classes = [IsAdmin | IsLogisticsAdmin]

    @extend_schema(request=AssignRiderSerializer)
    def post(self, request, pk):
        order = Order.objects.filter(pk=pk).first()
        if not order:
            return success_response(message="Order not found.", status_code=404)
        if order.status != OrderStatus.ACCEPTED:
            return success_response(message="Order must be accepted before rider assignment.", status_code=400)

        serializer = AssignRiderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        rider = User.objects.filter(id=serializer.validated_data["rider_id"], role=Role.RIDER).first()
        if not rider:
            return success_response(message="Invalid rider.", status_code=400)

        order.rider = rider
        order.status = OrderStatus.ASSIGNED
        order.save(update_fields=["rider", "status"])
        OrderStatusHistory.objects.create(order=order, status=order.status, changed_by=request.user,
                                           note=f"Assigned to rider {rider.username}")
        return success_response(data=OrderSerializer(order).data)


class RiderOrdersView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsRider]

    def get_queryset(self):
        return Order.objects.filter(rider=self.request.user).order_by("-created_at")


class RiderUpdateStatusView(APIView):
    permission_classes = [IsRider]

    @extend_schema(request=RiderStatusUpdateSerializer)
    def post(self, request, pk):
        order = Order.objects.filter(pk=pk, rider=request.user).first()
        if not order:
            return success_response(message="Order not found.", status_code=404)

        serializer = RiderStatusUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        new_status = serializer.validated_data["status"]

        valid_transitions = {
            OrderStatus.ASSIGNED: [OrderStatus.OUT_FOR_DELIVERY],
            OrderStatus.OUT_FOR_DELIVERY: [OrderStatus.DELIVERED],
        }
        if new_status not in valid_transitions.get(order.status, []):
            return success_response(message=f"Cannot move from {order.status} to {new_status}.", status_code=400)

        order.status = new_status
        order.save(update_fields=["status"])
        OrderStatusHistory.objects.create(order=order, status=new_status, changed_by=request.user,
                                           note=f"Marked {new_status} by rider.")
        return success_response(data=OrderSerializer(order).data)