from django.urls import path
from .views import InitiatePaymentView, MyPaymentsView, AdminPaymentsView, ReviewPaymentView

urlpatterns = [
    path("initiate/", InitiatePaymentView.as_view(), name="payment-initiate"),
    path("my-payments/", MyPaymentsView.as_view(), name="my-payments"),
    path("admin-payments/", AdminPaymentsView.as_view(), name="admin-payments"),
    path("admin-payments/<int:pk>/review/", ReviewPaymentView.as_view(), name="payment-review"),
]