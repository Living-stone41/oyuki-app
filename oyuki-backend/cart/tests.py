from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APITestCase

from accounts.models import Role
from common.test_utils import create_user
from marketplace.models import State, LGA, Market, Category, Product, Unit
from .models import Cart, CartItem


def make_product(seller, quantity=10, price="1000.00"):
    state = State.objects.create(name="Lagos")
    lga = LGA.objects.create(state=state, name="Ikeja")
    market = Market.objects.create(lga=lga, name="Computer Village")
    category = Category.objects.create(name="Vegetables")
    return Product.objects.create(seller=seller, market=market, category=category,
                                   name="Tomatoes", price=price, unit=Unit.KG,
                                   quantity_available=quantity)


class CartTests(APITestCase):
    def setUp(self):
        self.seller = create_user(Role.SELLER, username="cartseller", email="cartseller@example.com")
        self.product = make_product(self.seller, quantity=10)
        self.customer = create_user(Role.CUSTOMER, username="cartcustomer", email="cartcustomer@example.com")
        login = self.client.post(reverse("login"), {"username": "cartcustomer", "password": "TestPass123!"},
                                  format="json")
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['data']['access']}")

    def test_get_cart_creates_empty_cart(self):
        response = self.client.get(reverse("cart"))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"]["items"], [])
        self.assertTrue(Cart.objects.filter(customer=self.customer).exists())

    def test_add_item_to_cart(self):
        response = self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 2},
                                     format="json")
        self.assertEqual(response.status_code, 201)
        self.assertEqual(len(response.data["data"]["items"]), 1)
        self.assertEqual(response.data["data"]["subtotal"], "2000.00")

    def test_adding_same_product_twice_increments_quantity(self):
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 2}, format="json")
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 3}, format="json")
        item = CartItem.objects.get(product=self.product)
        self.assertEqual(item.quantity, 5)

    def test_cannot_add_more_than_available_stock(self):
        response = self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 999},
                                     format="json")
        self.assertEqual(response.status_code, 400)

    def test_update_item_quantity(self):
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 2}, format="json")
        item = CartItem.objects.get(product=self.product)
        response = self.client.put(reverse("cart-item-update", args=[item.id]), {"quantity": 5}, format="json")
        self.assertEqual(response.status_code, 200)
        item.refresh_from_db()
        self.assertEqual(item.quantity, 5)

    def test_remove_item(self):
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 2}, format="json")
        item = CartItem.objects.get(product=self.product)
        response = self.client.delete(reverse("cart-item-remove", args=[item.id]))
        self.assertEqual(response.status_code, 200)
        self.assertFalse(CartItem.objects.filter(id=item.id).exists())

    def test_cannot_update_another_users_cart_item(self):
        self.client.post(reverse("cart-add"), {"product_id": self.product.id, "quantity": 2}, format="json")
        item = CartItem.objects.get(product=self.product)

        other = create_user(Role.CUSTOMER, username="othercustomer", email="othercustomer@example.com")
        login = self.client.post(reverse("login"), {"username": "othercustomer", "password": "TestPass123!"},
                                  format="json")
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['data']['access']}")

        response = self.client.put(reverse("cart-item-update", args=[item.id]), {"quantity": 1}, format="json")
        self.assertEqual(response.status_code, 404)