from django.urls import path
from .views import (
    NotificationListView, UnreadCountView, MarkReadView, MarkAllReadView,
    RegisterDeviceView, RemoveDeviceView,
)

urlpatterns = [
    path("", NotificationListView.as_view(), name="notification-list"),
    path("unread-count/", UnreadCountView.as_view(), name="notification-unread-count"),
    path("read-all/", MarkAllReadView.as_view(), name="notification-read-all"),
    path("<int:pk>/read/", MarkReadView.as_view(), name="notification-read"),
    path("devices/", RegisterDeviceView.as_view(), name="device-register"),
    path("devices/remove/", RemoveDeviceView.as_view(), name="device-remove"),
]