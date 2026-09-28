from rest_framework import serializers
from .models import Notification, DevicePlatform


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ["id", "notification_type", "title", "message",
                  "related_entity_type", "related_entity_id",
                  "is_read", "read_at", "created_at"]
        read_only_fields = fields


class RegisterDeviceSerializer(serializers.Serializer):
    token = serializers.CharField(max_length=255)
    platform = serializers.ChoiceField(choices=DevicePlatform.choices)


class RemoveDeviceSerializer(serializers.Serializer):
    token = serializers.CharField(max_length=255)