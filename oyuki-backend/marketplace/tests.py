from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APITestCase

from accounts.models import Role
from common.test_utils import create_user
from .models import State, LGA, Market, Category, Product, Unit, Wishlist


def make_location():
    state = State.objects.create(name="Lagos")
    lga = LGA.objects.create(state=state, name="Ikeja")
    market = Market.objects.create(lga=lga, name="Computer Village")
    category = Category.objects.create(name="Vegetables")
    return state, lga, market, category


class ProductListTests(APITestCase):
    def setUp(self):
        _, _, self.market, self.category = make_location()
        self.seller = create_user(Role.SELLER, username="seller1", email="seller1@example.com")
        self.product = Product.objects.create(
            seller=self.seller, market=self.market, category=self.category,
            name="Fresh Tomatoes", price="1500.00", unit=Unit.KG, quantity_available=50,
        )

    def test_anyone_can_list_products_without_auth(self):
        response = self.client.get(reverse("product-list"))
        self.assertEqual(response.status_code, 200)
        names = [p["name"] for p in response.data["data"]["results"]]
        self.assertIn("Fresh Tomatoes", names)

    def test_inactive_products_are_hidden(self):
        self.product.is_active = False
        self.product.save(update_fields=["is_active"])
        response = self.client.get(reverse("product-list"))
        names = [p["name"] for p in response.data["data"]["results"]]
        self.assertNotIn("Fresh Tomatoes", names)

    def test_search_filters_by_name(self):
        response = self.client.get(reverse("product-list"), {"search": "tomato"})
        self.assertEqual(len(response.data["data"]["results"]), 1)

        response = self.client.get(reverse("product-list"), {"search": "yam"})
        self.assertEqual(len(response.data["data"]["results"]), 0)


class SellerProductTests(APITestCase):
    def setUp(self):
        _, _, self.market, self.category = make_location()
        self.seller = create_user(Role.SELLER, username="seller2", email="seller2@example.com")
        self.other_seller = create_user(Role.SELLER, username="seller3", email="seller3@example.com")
        self.customer = create_user(Role.CUSTOMER, username="cust1", email="cust1@example.com")

    def login_as(self, username):
        response = self.client.post(reverse("login"), {"username": username, "password": "TestPass123!"},
                                     format="json")
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['data']['access']}")

    def test_seller_can_create_product(self):
        self.login_as("seller2")
        payload = {"name": "Yam", "description": "Fresh yam", "price": "800.00", "unit": "KG",
                   "quantity_available": 30, "category": self.category.id, "market": self.market.id}
        response = self.client.post(reverse("my-product-list-create"), payload, format="json")
        self.assertEqual(response.status_code, 201)
        self.assertEqual(Product.objects.get(name="Yam").seller, self.seller)

    def test_customer_cannot_create_product(self):
        self.login_as("cust1")
        payload = {"name": "Yam", "price": "800.00", "unit": "KG",
                   "quantity_available": 30, "category": self.category.id, "market": self.market.id}
        response = self.client.post(reverse("my-product-list-create"), payload, format="json")
        self.assertEqual(response.status_code, 403)

    def test_seller_cannot_edit_another_sellers_product(self):
        product = Product.objects.create(seller=self.other_seller, market=self.market, category=self.category,
                                          name="Onions", price="500.00", unit=Unit.KG, quantity_available=10)
        self.login_as("seller2")
        response = self.client.patch(reverse("my-product-detail", args=[product.id]),
                                      {"price": "1.00"}, format="json")
        self.assertEqual(response.status_code, 404)


class WishlistTests(APITestCase):
    def setUp(self):
        _, _, self.market, self.category = make_location()
        self.seller = create_user(Role.SELLER, username="seller4", email="seller4@example.com")
        self.product = Product.objects.create(
            seller=self.seller, market=self.market, category=self.category,
            name="Pepper", price="300.00", unit=Unit.KG, quantity_available=20,
        )
        self.customer = create_user(Role.CUSTOMER, username="cust2", email="cust2@example.com")
        login = self.client.post(reverse("login"), {"username": "cust2", "password": "TestPass123!"},
                                  format="json")
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['data']['access']}")

    def test_add_and_list_wishlist(self):
        response = self.client.post(reverse("wishlist"), {"product": self.product.id}, format="json")
        self.assertEqual(response.status_code, 201)

        response = self.client.get(reverse("wishlist"))
        self.assertEqual(len(response.data["data"]["results"]), 1)

    def test_cannot_wishlist_same_product_twice(self):
        self.client.post(reverse("wishlist"), {"product": self.product.id}, format="json")
        response = self.client.post(reverse("wishlist"), {"product": self.product.id}, format="json")
        self.assertEqual(response.status_code, 400)