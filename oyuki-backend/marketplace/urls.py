from django.urls import path
from .views import (
    StateListView, LGAListView, MarketListView, CategoryListView,
    ProductListView, ProductDetailView,
    MyProductListCreateView, MyProductDetailView,
    WishlistListCreateView, WishlistDeleteView,
)

urlpatterns = [
    path("states/", StateListView.as_view(), name="state-list"),
    path("lgas/", LGAListView.as_view(), name="lga-list"),
    path("markets/", MarketListView.as_view(), name="market-list"),
    path("categories/", CategoryListView.as_view(), name="category-list"),

    path("products/", ProductListView.as_view(), name="product-list"),
    path("products/<int:pk>/", ProductDetailView.as_view(), name="product-detail"),

    path("my-products/", MyProductListCreateView.as_view(), name="my-product-list-create"),
    path("my-products/<int:pk>/", MyProductDetailView.as_view(), name="my-product-detail"),

    path("wishlist/", WishlistListCreateView.as_view(), name="wishlist"),
    path("wishlist/<int:pk>/", WishlistDeleteView.as_view(), name="wishlist-delete"),
]