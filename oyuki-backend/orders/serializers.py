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

    class Meta:
        model = Order
        fields = ["id", "customer", "customer_name", "seller", "seller_name",
                  "rider", "rider_name", "status", "delivery_address",
                  "delivery_fee", "subtotal", "total", "reject_reason",
                  "items", "status_history", "created_at"]
        read_only_fields = ["customer", "seller", "subtotal", "total"]


class CheckoutSerializer(serializers.Serializer):
    delivery_address = serializers.CharField()