import logging
from django.db import transaction

from .models import Notification, DeviceToken

logger = logging.getLogger(__name__)


def send_push(user, title, message, data=None):
    """Push delivery seam. Real FCM sending goes here once the Firebase project exists."""
    tokens = list(DeviceToken.objects.filter(user=user).values_list("token", flat=True))
    if not tokens:
        return
    # TODO: send via Firebase Admin SDK (messaging.send_each_for_multicast)
    logger.warning("PUSH not sent (FCM not configured) -> user %s: %s", user.pk, title)


def notify(user, kind, title, message, entity_type="", entity_id=None):
    notification = Notification.objects.create(
        user=user,
        notification_type=kind,
        title=title,
        message=message,
        related_entity_type=entity_type,
        related_entity_id=entity_id,
    )
    payload = {"type": kind, "entity_type": entity_type, "entity_id": entity_id}
    transaction.on_commit(lambda: send_push(user, title, message, payload))
    return notification