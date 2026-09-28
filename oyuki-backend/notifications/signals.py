from django.db.models.signals import post_save
from django.dispatch import receiver

from orders.models import OrderStatusHistory, OrderStatus
from payments.models import PaymentAuditLog, PaymentStatus
from .models import NotificationType
from .services import notify


@receiver(post_save, sender=OrderStatusHistory)
def order_status_notifications(sender, instance, created, **kwargs):
    if not created:
        return

    order = instance.order
    status = instance.status

    def send(user, title, message):
        if user:
            notify(user, NotificationType.ORDER, title, message, "order", order.id)

    if status == OrderStatus.PENDING:
        send(order.seller, "New order", f"You have a new order #{order.id}.")
        send(order.customer, "Order placed", f"Your order #{order.id} has been placed.")
    elif status == OrderStatus.ACCEPTED:
        send(order.customer, "Order accepted", f"The seller accepted your order #{order.id}.")
    elif status == OrderStatus.REJECTED:
        reason = f" Reason: {order.reject_reason}" if order.reject_reason else ""
        send(order.customer, "Order rejected", f"Your order #{order.id} was rejected.{reason}")
    elif status == OrderStatus.ASSIGNED:
        send(order.rider, "New delivery", f"You have been assigned order #{order.id}.")
        send(order.customer, "Rider assigned", f"A rider has been assigned to order #{order.id}.")
    elif status == OrderStatus.OUT_FOR_DELIVERY:
        send(order.customer, "Out for delivery", f"Your order #{order.id} is on its way.")
    elif status == OrderStatus.DELIVERED:
        send(order.customer, "Order delivered", f"Your order #{order.id} was delivered.")
        send(order.seller, "Order delivered", f"Order #{order.id} was delivered.")
    elif status == OrderStatus.CANCELLED:
        send(order.customer, "Order cancelled", f"Your order #{order.id} was cancelled.")
        send(order.seller, "Order cancelled", f"Order #{order.id} was cancelled.")


@receiver(post_save, sender=PaymentAuditLog)
def payment_notifications(sender, instance, created, **kwargs):
    if not created:
        return

    payment = instance.payment
    if instance.to_status == PaymentStatus.CONFIRMED:
        title, message = "Payment confirmed", f"Your payment {payment.reference} for order #{payment.order_id} was confirmed."
    elif instance.to_status == PaymentStatus.FAILED:
        title, message = "Payment failed", f"Your payment {payment.reference} for order #{payment.order_id} could not be confirmed."
    else:
        return

    notify(payment.customer, NotificationType.PAYMENT, title, message, "payment", payment.id)