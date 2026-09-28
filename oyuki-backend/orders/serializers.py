from rest_framework import serializers
from .models import Order, OrderItem, OrderStatusHistory


class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = ["id", "product", "product_name", "unit_price", "quantity", "line_total"]


class OrderStatusHistorySerializer(serializers.ModelSerializer):
    changed_by_name = serializers.CharField(source="changed_by.username", read_only=True)

    class Meta:
        model = OrderStatusHistory
        fields = ["id", "status", "changed_by_name", "note", "created_at"]


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    status_history = OrderStatusHistorySerializer(many=True, read_only=True)
    customer_name = serializers.CharField(source="customer.username", read_only=True)
    seller_name = serializers.CharField(source="seller.username", read_only=True)
    rider_name = serializers.CharField(source="rider.username", read_only=True)
    payment_status = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = ["id", "customer", "customer_name", "seller", "seller_name",
                  "rider", "rider_name", "status", "delivery_address",
                  "delivery_fee", "subtotal", "total", "payment_status",
                  "reject_reason", "items", "status_history", "created_at"]
        read_only_fields = ["customer", "seller", "subtotal", "total"]

    def get_payment_status(self, obj):
        latest = obj.payments.order_by("-created_at").first()
        return latest.status if latest else None


class CheckoutSerializer(serializers.Serializer):
    delivery_address = serializers.CharField()

class SellerOrderActionSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=["ACCEPT", "REJECT"])
    reject_reason = serializers.CharField(required=False, allow_blank=True)


class AssignRiderSerializer(serializers.Serializer):
    rider_id = serializers.IntegerField()


class RiderStatusUpdateSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=["OUT_FOR_DELIVERY", "DELIVERED"])