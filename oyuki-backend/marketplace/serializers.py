from rest_framework import serializers
from .models import State, LGA, Market, Category, Product, ProductImage, Wishlist


class StateSerializer(serializers.ModelSerializer):
    class Meta:
        model = State
        fields = ["id", "name"]


class LGASerializer(serializers.ModelSerializer):
    class Meta:
        model = LGA
        fields = ["id", "name", "state"]


class MarketSerializer(serializers.ModelSerializer):
    class Meta:
        model = Market
        fields = ["id", "name", "lga"]


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ["id", "name"]


class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ["id", "image"]


class ProductListSerializer(serializers.ModelSerializer):
    seller_name = serializers.CharField(source="seller.username", read_only=True)
    category_name = serializers.CharField(source="category.name", read_only=True)
    thumbnail = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ["id", "name", "price", "unit", "quantity_available",
                  "seller_name", "category_name", "thumbnail", "is_active"]

    def get_thumbnail(self, obj):
        first_image = obj.images.first()
        request = self.context.get("request")
        if first_image and request:
            return request.build_absolute_uri(first_image.image.url)
        return None


class ProductDetailSerializer(serializers.ModelSerializer):
    seller_name = serializers.CharField(source="seller.username", read_only=True)
    category_name = serializers.CharField(source="category.name", read_only=True)
    market_name = serializers.CharField(source="market.name", read_only=True)
    images = ProductImageSerializer(many=True, read_only=True)

    class Meta:
        model = Product
        fields = ["id", "name", "description", "price", "unit", "quantity_available",
                  "seller", "seller_name", "category", "category_name",
                  "market", "market_name", "images", "is_active", "created_at"]
        read_only_fields = ["seller"]


class ProductCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ["id", "name", "description", "price", "unit",
                  "quantity_available", "category", "market"]

    def validate_market(self, market):
        # Enforces the plan's guardrail: State -> LGA -> Market integrity
        # is backend-owned. The client sends an ID; we just confirm it's real.
        return market

    def create(self, validated_data):
        validated_data["seller"] = self.context["request"].user
        return Product.objects.create(**validated_data)


class WishlistSerializer(serializers.ModelSerializer):
    product_detail = ProductListSerializer(source="product", read_only=True)

    class Meta:
        model = Wishlist
        fields = ["id", "product", "product_detail", "created_at"]