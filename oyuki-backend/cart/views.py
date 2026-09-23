from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema

from common.responses import success_response
from marketplace.models import Product
from .models import Cart, CartItem
from .serializers import CartSerializer, AddToCartSerializer, UpdateCartItemSerializer


def get_or_create_cart(user):
    cart, _ = Cart.objects.get_or_create(customer=user)
    return cart


class CartView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        cart = get_or_create_cart(request.user)
        return success_response(data=CartSerializer(cart).data)


class AddToCartView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=AddToCartSerializer)
    def post(self, request):
        serializer = AddToCartSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        product = Product.objects.filter(
            id=serializer.validated_data["product_id"], is_active=True
        ).first()
        if not product:
            return success_response(message="Product not found or unavailable.", status_code=404)

        quantity = serializer.validated_data["quantity"]
        if quantity > product.quantity_available:
            return success_response(
                message=f"Only {product.quantity_available} available.", status_code=400
            )

        cart = get_or_create_cart(request.user)
        item, created = CartItem.objects.get_or_create(
            cart=cart, product=product, defaults={"quantity": quantity}
        )
        if not created:
            item.quantity += quantity
            item.save(update_fields=["quantity"])

        return success_response(data=CartSerializer(cart).data,
                                 status_code=status.HTTP_201_CREATED)


class UpdateCartItemView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=UpdateCartItemSerializer)
    def put(self, request, pk):
        serializer = UpdateCartItemSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        item = CartItem.objects.filter(pk=pk, cart__customer=request.user).first()
        if not item:
            return success_response(message="Cart item not found.", status_code=404)

        quantity = serializer.validated_data["quantity"]
        if quantity > item.product.quantity_available:
            return success_response(
                message=f"Only {item.product.quantity_available} available.", status_code=400
            )

        item.quantity = quantity
        item.save(update_fields=["quantity"])
        return success_response(data=CartSerializer(item.cart).data)


class RemoveCartItemView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        item = CartItem.objects.filter(pk=pk, cart__customer=request.user).first()
        if not item:
            return success_response(message="Cart item not found.", status_code=404)
        cart = item.cart
        item.delete()
        return success_response(data=CartSerializer(cart).data)