from django.shortcuts import render
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema

from common.responses import success_response
from .models import Notification, DeviceToken
from .serializers import NotificationSerializer, RegisterDeviceSerializer, RemoveDeviceSerializer


class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = Notification.objects.filter(user=self.request.user)
        if self.request.query_params.get("unread") == "true":
            qs = qs.filter(is_read=False)
        return qs


class UnreadCountView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        count = Notification.objects.filter(user=request.user, is_read=False).count()
        return success_response(data={"unread": count})


class MarkReadView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=None)
    def patch(self, request, pk):
        notification = Notification.objects.filter(pk=pk, user=request.user).first()
        if not notification:
            return success_response(message="Notification not found.", status_code=404)
        if not notification.is_read:
            notification.is_read = True
            notification.read_at = timezone.now()
            notification.save(update_fields=["is_read", "read_at"])
        return success_response(data=NotificationSerializer(notification).data)


class MarkAllReadView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=None)
    def post(self, request):
        updated = Notification.objects.filter(user=request.user, is_read=False).update(
            is_read=True, read_at=timezone.now()
        )
        return success_response(data={"marked_read": updated})


class RegisterDeviceView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=RegisterDeviceSerializer)
    def post(self, request):
        serializer = RegisterDeviceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # If this device token was previously tied to another account, it moves to this one
        _, created = DeviceToken.objects.update_or_create(
            token=serializer.validated_data["token"],
            defaults={"user": request.user, "platform": serializer.validated_data["platform"]},
        )
        return success_response(
            message="Device registered.",
            status_code=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )


class RemoveDeviceView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=RemoveDeviceSerializer)
    def post(self, request):
        serializer = RemoveDeviceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        DeviceToken.objects.filter(token=serializer.validated_data["token"], user=request.user).delete()
        return success_response(message="Device removed.")