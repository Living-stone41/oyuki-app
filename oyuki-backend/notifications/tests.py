from django.urls import reverse
from rest_framework.test import APITestCase

from accounts.models import Role
from common.test_utils import create_user, login
from marketplace.models import State, LGA, Market, Category, Product, Unit
from .models import Notification, DeviceToken


def make_market_and_category():
    state = State.objects.create(name="Lagos")
    lga = LGA.objects.create(state=state, name="Ikeja")
    market = Market.objects.create(lga=lga, name="Computer Village")
    category = Category.objects.create(name="Vegetables")
    return market, category


class OrderNotificationSignalTests(APITestCase):
    def setUp(self):
        self.market, self.category = make_market_and_category()
        self.seller = create_user(Role.SELLER, username="notifyseller", email="notifyseller@example.com")
        self.product = Product.objects.create(seller=self.seller, market=self.market, category=self.category,
                                               name="Beans", price="900.00", unit=Unit.KG, quantity_available=10)
        self.customer = create_user(Role.CUSTOMER, username="notifycust", email="notifycust@example.com")

    def test_checkout_notifies_both_customer_and_seller(self):
        login(self.client, "notifycust")
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 1}, format="json")
        checkout = self.client.post(reverse("checkout"), {"delivery_address": "1 Test St"}, format="json")
        order_id = checkout.json()["data"][0]["id"]

        self.assertTrue(Notification.objects.filter(user=self.customer, title="Order placed",
                                                      related_entity_id=order_id).exists())
        self.assertTrue(Notification.objects.filter(user=self.seller, title="New order",
                                                      related_entity_id=order_id).exists())

    def test_accept_notifies_customer(self):
        login(self.client, "notifycust")
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 1}, format="json")
        checkout = self.client.post(reverse("checkout"), {"delivery_address": "1 Test St"}, format="json")
        order_id = checkout.json()["data"][0]["id"]

        login(self.client, "notifyseller")
        self.client.post(reverse("seller-order-action", args=[order_id]), {"action": "ACCEPT"}, format="json")

        self.assertTrue(Notification.objects.filter(user=self.customer, title="Order accepted",
                                                      related_entity_id=order_id).exists())


class NotificationListTests(APITestCase):
    def setUp(self):
        self.customer = create_user(Role.CUSTOMER, username="listcust", email="listcust@example.com")
        self.other = create_user(Role.CUSTOMER, username="listcust2", email="listcust2@example.com")
        self.n1 = Notification.objects.create(user=self.customer, title="First", message="msg1")
        self.n2 = Notification.objects.create(user=self.customer, title="Second", message="msg2")
        Notification.objects.create(user=self.other, title="NotYours", message="msg3")
        login(self.client, "listcust")

    def test_list_only_shows_own_notifications(self):
        response = self.client.get(reverse("notification-list"))
        titles = [n["title"] for n in response.json()["data"]["results"]]
        self.assertIn("First", titles)
        self.assertIn("Second", titles)
        self.assertNotIn("NotYours", titles)

    def test_unread_count(self):
        response = self.client.get(reverse("notification-unread-count"))
        self.assertEqual(response.json()["data"]["unread"], 2)

    def test_mark_one_read_decrements_count(self):
        self.client.patch(reverse("notification-read", args=[self.n1.id]))
        response = self.client.get(reverse("notification-unread-count"))
        self.assertEqual(response.json()["data"]["unread"], 1)

    def test_mark_all_read(self):
        self.client.post(reverse("notification-read-all"))
        response = self.client.get(reverse("notification-unread-count"))
        self.assertEqual(response.json()["data"]["unread"], 0)

    def test_cannot_mark_another_users_notification_read(self):
        other_notification = Notification.objects.get(title="NotYours")
        response = self.client.patch(reverse("notification-read", args=[other_notification.id]))
        self.assertEqual(response.status_code, 404)


class DeviceTokenTests(APITestCase):
    def setUp(self):
        self.customer = create_user(Role.CUSTOMER, username="devcust", email="devcust@example.com")
        login(self.client, "devcust")

    def test_register_device_creates_token(self):
        response = self.client.post(reverse("device-register"),
                                     {"token": "abc123", "platform": "ANDROID"}, format="json")
        self.assertEqual(response.status_code, 201)
        self.assertTrue(DeviceToken.objects.filter(token="abc123", user=self.customer).exists())

    def test_registering_same_token_again_updates_not_duplicates(self):
        self.client.post(reverse("device-register"), {"token": "abc123", "platform": "ANDROID"}, format="json")
        response = self.client.post(reverse("device-register"),
                                     {"token": "abc123", "platform": "IOS"}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(DeviceToken.objects.filter(token="abc123").count(), 1)

    def test_remove_device(self):
        self.client.post(reverse("device-register"), {"token": "abc123", "platform": "ANDROID"}, format="json")
        response = self.client.post(reverse("device-remove"), {"token": "abc123"}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertFalse(DeviceToken.objects.filter(token="abc123").exists())