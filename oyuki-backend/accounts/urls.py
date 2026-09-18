from django.urls import path
from .views import (
    RegisterView, VerifyOTPView, LoginView, ForgotPasswordView, ResetPasswordView,
    MeView, AdminPingView,
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("verify-otp/", VerifyOTPView.as_view(), name="verify-otp"),
    path("login/", LoginView.as_view(), name="login"),
    path("forgot-password/", ForgotPasswordView.as_view(), name="forgot-password"),
    path("reset-password/", ResetPasswordView.as_view(), name="reset-password"),
    path("me/", MeView.as_view(), name="me"),
    path("admin-ping/", AdminPingView.as_view(), name="admin-ping"),
]