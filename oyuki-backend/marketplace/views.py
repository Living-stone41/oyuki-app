from django.shortcuts import render
from rest_framework import generics, filters
from rest_framework.permissions import IsAuthenticated, AllowAny
from django_filters.rest_framework import DjangoFilterBackend

from common.responses import success_response
from .models import State, LGA, Market, Category, Product, Wishlist
from .serializers import (
    StateSerializer, LGASerializer, MarketSerializer, CategorySerializer,
    ProductListSerializer, ProductDetailSerializer, ProductCreateSerializer,
    WishlistSerializer,
)
from accounts.permissions import IsSeller


class StateListView(generics.ListAPIView):
    queryset = State.objects.all()
    serializer_class = StateSerializer
    permission_classes = [AllowAny]


class LGAListView(generics.ListAPIView):
    serializer_class = LGASerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = LGA.objects.all()
        state_id = self.request.query_params.get("state")
        if state_id:
            qs = qs.filter(state_id=state_id)
        return qs


class MarketListView(generics.ListAPIView):
    serializer_class = MarketSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = Market.objects.all()
        lga_id = self.request.query_params.get("lga")
        if lga_id:
            qs = qs.filter(lga_id=lga_id)
        return qs


class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]


class ProductListView(generics.ListAPIView):
    serializer_class = ProductListSerializer
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ["category", "market", "seller"]
    search_fields = ["name", "description"]

    def get_queryset(self):
        return Product.objects.filter(is_active=True).select_related("seller", "category")


class ProductDetailView(generics.RetrieveAPIView):
    queryset = Product.objects.filter(is_active=True)
    serializer_class = ProductDetailSerializer
    permission_classes = [AllowAny]


class MyProductListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsSeller]

    def get_queryset(self):
        return Product.objects.filter(seller=self.request.user)

    def get_serializer_class(self):
        return ProductCreateSerializer if self.request.method == "POST" else ProductDetailSerializer


class MyProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ProductDetailSerializer
    permission_classes = [IsSeller]

    def get_queryset(self):
        return Product.objects.filter(seller=self.request.user)


class WishlistListCreateView(generics.ListCreateAPIView):
    serializer_class = WishlistSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Wishlist.objects.filter(customer=self.request.user)

    def perform_create(self, serializer):
        serializer.save(customer=self.request.user)


class WishlistDeleteView(generics.DestroyAPIView):
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Wishlist.objects.filter(customer=self.request.user)
