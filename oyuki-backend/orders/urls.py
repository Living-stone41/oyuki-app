from django.urls import path
from .views import (
    CheckoutView, MyOrdersView, MyOrderDetailView,
    SellerOrdersView, SellerOrderActionView,
    AdminOrdersView, AssignRiderView,
    RiderOrdersView, RiderUpdateStatusView,
)

urlpatterns = [
    path("checkout/", CheckoutView.as_view(), name="checkout"),
    path("my-orders/", MyOrdersView.as_view(), name="my-orders"),
    path("my-orders/<int:pk>/", MyOrderDetailView.as_view(), name="my-order-detail"),

    path("seller-orders/", SellerOrdersView.as_view(), name="seller-orders"),
    path("seller-orders/<int:pk>/action/", SellerOrderActionView.as_view(), name="seller-order-action"),

    path("admin-orders/", AdminOrdersView.as_view(), name="admin-orders"),
    path("admin-orders/<int:pk>/assign-rider/", AssignRiderView.as_view(), name="assign-rider"),

    path("rider-orders/", RiderOrdersView.as_view(), name="rider-orders"),
    path("rider-orders/<int:pk>/update-status/", RiderUpdateStatusView.as_view(), name="rider-update-status"),
]