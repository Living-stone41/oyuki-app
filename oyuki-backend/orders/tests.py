from django.urls import reverse
from rest_framework.test import APITestCase

from accounts.models import Role
from common.test_utils import create_user, login
from marketplace.models import State, LGA, Market, Category, Product, Unit
from .models import Order, OrderStatus


def make_market_and_category():
    state = State.objects.create(name="Lagos")
    lga = LGA.objects.create(state=state, name="Ikeja")
    market = Market.objects.create(lga=lga, name="Computer Village")
    category = Category.objects.create(name="Vegetables")
    return market, category


def make_product(seller, market, category, name="Tomatoes", quantity=10, price="1000.00"):
    return Product.objects.create(seller=seller, market=market, category=category,
                                   name=name, price=price, unit=Unit.KG, quantity_available=quantity)


class CheckoutTests(APITestCase):
    def setUp(self):
        self.market, self.category = make_market_and_category()
        self.seller = create_user(Role.SELLER, username="ordseller", email="ordseller@example.com")
        self.product = make_product(self.seller, self.market, self.category, quantity=10)
        self.customer = create_user(Role.CUSTOMER, username="ordcustomer", email="ordcustomer@example.com")
        login(self.client, "ordcustomer")

    def test_checkout_fails_with_empty_cart(self):
        response = self.client.post(reverse("checkout"), {"delivery_address": "1 Test St"}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_checkout_creates_order_and_decrements_stock(self):
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 3}, format="json")
        response = self.client.post(reverse("checkout"), {"delivery_address": "1 Test St"}, format="json")

        self.assertEqual(response.status_code, 201)
        order = Order.objects.get(customer=self.customer)
        self.assertEqual(order.status, OrderStatus.PENDING)
        self.assertEqual(str(order.subtotal), "3000.00")

        self.product.refresh_from_db()
        self.assertEqual(self.product.quantity_available, 7)

        cart_response = self.client.get(reverse("cart"))
        self.assertEqual(cart_response.data["data"]["items"], [])

    def test_checkout_fails_when_exceeding_stock(self):
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 5}, format="json")
        self.product.quantity_available = 2
        self.product.save(update_fields=["quantity_available"])

        response = self.client.post(reverse("checkout"), {"delivery_address": "1 Test St"}, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertFalse(Order.objects.filter(customer=self.customer).exists())

    def test_checkout_splits_orders_by_seller(self):
        other_seller = create_user(Role.SELLER, username="ordseller2", email="ordseller2@example.com")
        other_product = make_product(other_seller, self.market, self.category, name="Yam", quantity=5)

        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 1}, format="json")
        self.client.post(reverse("cart-add"), {"product_id": other_product.id, "quantity": 1}, format="json")

        response = self.client.post(reverse("checkout"), {"delivery_address": "1 Test St"}, format="json")
        self.assertEqual(response.status_code, 201)
        self.assertEqual(len(response.data["data"]), 2)
        self.assertEqual(Order.objects.filter(customer=self.customer).count(), 2)


class OrderLifecycleTests(APITestCase):
    def setUp(self):
        self.market, self.category = make_market_and_category()
        self.seller = create_user(Role.SELLER, username="lcseller", email="lcseller@example.com")
        self.other_seller = create_user(Role.SELLER, username="lcseller2", email="lcseller2@example.com")
        self.product = make_product(self.seller, self.market, self.category, quantity=10)
        self.customer = create_user(Role.CUSTOMER, username="lccustomer", email="lccustomer@example.com")
        self.rider = create_user(Role.RIDER, username="lcrider", email="lcrider@example.com")
        self.admin = create_user(Role.ADMIN, username="lcadmin", email="lcadmin@example.com")

        login(self.client, "lccustomer")
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 2}, format="json")
        checkout = self.client.post(reverse("checkout"), {"delivery_address": "1 Test St"}, format="json")
        self.order_id = checkout.data["data"][0]["id"]

    def test_seller_can_accept_own_order(self):
        login(self.client, "lcseller")
        response = self.client.post(reverse("seller-order-action", args=[self.order_id]),
                                     {"action": "ACCEPT"}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"]["status"], OrderStatus.ACCEPTED)

    def test_other_seller_cannot_act_on_order(self):
        login(self.client, "lcseller2")
        response = self.client.post(reverse("seller-order-action", args=[self.order_id]),
                                     {"action": "ACCEPT"}, format="json")
        self.assertEqual(response.status_code, 404)

    def test_reject_restocks_product(self):
        self.product.refresh_from_db()
        stock_after_checkout = self.product.quantity_available

        login(self.client, "lcseller")
        response = self.client.post(reverse("seller-order-action", args=[self.order_id]),
                                     {"action": "REJECT", "reject_reason": "Out of stock"}, format="json")
        self.assertEqual(response.status_code, 200)

        self.product.refresh_from_db()
        self.assertEqual(self.product.quantity_available, stock_after_checkout + 2)

    def test_cannot_assign_rider_before_acceptance(self):
        login(self.client, "lcadmin")
        response = self.client.post(reverse("assign-rider", args=[self.order_id]),
                                     {"rider_id": self.rider.id}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_full_lifecycle_to_delivered(self):
        login(self.client, "lcseller")
        self.client.post(reverse("seller-order-action", args=[self.order_id]), {"action": "ACCEPT"}, format="json")

        login(self.client, "lcadmin")
        response = self.client.post(reverse("assign-rider", args=[self.order_id]),
                                     {"rider_id": self.rider.id}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"]["status"], OrderStatus.ASSIGNED)

        login(self.client, "lcrider")
        skip = self.client.post(reverse("rider-update-status", args=[self.order_id]),
                                 {"status": "DELIVERED"}, format="json")
        self.assertEqual(skip.status_code, 400)

        step1 = self.client.post(reverse("rider-update-status", args=[self.order_id]),
                                  {"status": "OUT_FOR_DELIVERY"}, format="json")
        self.assertEqual(step1.status_code, 200)

        step2 = self.client.post(reverse("rider-update-status", args=[self.order_id]),
                                  {"status": "DELIVERED"}, format="json")
        self.assertEqual(step2.status_code, 200)
        self.assertEqual(step2.data["data"]["status"], OrderStatus.DELIVERED)

        login(self.client, "lccustomer")
        detail = self.client.get(reverse("my-order-detail", args=[self.order_id]))
        statuses = [h["status"] for h in detail.json()["data"]["status_history"]]
        self.assertEqual(statuses[-1], OrderStatus.DELIVERED)

    def test_customer_cannot_view_another_customers_order(self):
        other_customer = create_user(Role.CUSTOMER, username="lccustomer2", email="lccustomer2@example.com")
        login(self.client, "lccustomer2")
        response = self.client.get(reverse("my-order-detail", args=[self.order_id]))
        self.assertEqual(response.status_code, 404)