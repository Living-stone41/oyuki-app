from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema
from django.contrib.auth import get_user_model, authenticate
from django.conf import settings
from .utils import create_otp, verify_otp, send_otp_email

from common.responses import success_response
from .serializers import (
    RegisterSerializer, UserSerializer, LoginSerializer,
    VerifyOTPSerializer, ForgotPasswordSerializer, ResetPasswordSerializer,
)
from .models import AccountStatus
from .utils import create_otp, verify_otp

User = get_user_model()


def tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {"access": str(refresh.access_token), "refresh": str(refresh)}


class RegisterView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(request=RegisterSerializer)
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        code = create_otp(user, purpose="VERIFY_EMAIL")
        send_otp_email(user, code, "VERIFY_EMAIL")

        data = {"user_id": user.id}
        if settings.DEBUG:
            data["debug_otp"] = code  # only visible in local dev, never in production

        return success_response(
            data=data,
            message="Registered. Verify your email with the OTP sent.",
            status_code=status.HTTP_201_CREATED,
        )


class VerifyOTPView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(request=VerifyOTPSerializer)
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = User.objects.filter(id=serializer.validated_data["user_id"]).first()
        if not user:
            return success_response(message="Invalid user.", status_code=400)

        ok, msg = verify_otp(user, serializer.validated_data["code"], purpose="VERIFY_EMAIL")
        if not ok:
            return success_response(message=msg, status_code=400)

        user.status = AccountStatus.ACTIVE
        user.save(update_fields=["status"])
        return success_response(data=tokens_for_user(user), message="Email verified.")


class LoginView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(request=LoginSerializer)
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = authenticate(
            username=serializer.validated_data["username"],
            password=serializer.validated_data["password"],
        )
        if not user:
            return success_response(message="Invalid credentials.", status_code=401)
        if user.status != AccountStatus.ACTIVE:
            return success_response(message=f"Account is {user.status}.", status_code=403)

        data = tokens_for_user(user)
        data["user"] = UserSerializer(user).data
        return success_response(data=data, message="Login successful.")


class ForgotPasswordView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(request=ForgotPasswordSerializer)
    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = User.objects.filter(email=serializer.validated_data["email"]).first()
        if user:
            code = create_otp(user, purpose="RESET_PASSWORD")
            send_otp_email(user, code, "RESET_PASSWORD")
            data = {"debug_otp": code} if settings.DEBUG else None
            return success_response(message="If that email exists, an OTP was sent.", data=data)
        return success_response(message="If that email exists, an OTP was sent.")


class ResetPasswordView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(request=ResetPasswordSerializer)
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = User.objects.filter(email=serializer.validated_data["email"]).first()
        if not user:
            return success_response(message="Invalid request.", status_code=400)

        ok, msg = verify_otp(user, serializer.validated_data["code"], purpose="RESET_PASSWORD")
        if not ok:
            return success_response(message=msg, status_code=400)

        user.set_password(serializer.validated_data["new_password"])
        user.save()
        return success_response(message="Password reset successful.")

from rest_framework.permissions import IsAuthenticated
from .permissions import IsAdmin


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return success_response(data=UserSerializer(request.user).data)


class AdminPingView(APIView):
    permission_classes = [IsAdmin]

    def get(self, request):
        return success_response(message="You are an authenticated ADMIN. Access granted.")