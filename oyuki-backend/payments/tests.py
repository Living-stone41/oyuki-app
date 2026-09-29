from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from rest_framework.test import APITestCase

from accounts.models import Role
from common.test_utils import create_user, login, make_test_image
from marketplace.models import State, LGA, Market, Category, Product, Unit
from orders.models import Order
from .models import Payment, PaymentStatus


def make_paid_setup():
    state = State.objects.create(name="Lagos")
    lga = LGA.objects.create(state=state, name="Ikeja")
    market = Market.objects.create(lga=lga, name="Computer Village")
    category = Category.objects.create(name="Vegetables")
    seller = create_user(Role.SELLER, username="paysell", email="paysell@example.com")
    product = Product.objects.create(seller=seller, market=market, category=category,
                                      name="Rice", price="2000.00", unit=Unit.KG, quantity_available=10)
    return seller, product


def checkout_one_order(client, product, address="1 Test St"):
    client.post(reverse("cart-add"), {"product_id": product.id, "quantity": 1}, format="json")
    response = client.post(reverse("checkout"), {"delivery_address": address}, format="json")
    return response.json()["data"][0]["id"]


class InitiatePaymentTests(APITestCase):
    def setUp(self):
        self.seller, self.product = make_paid_setup()
        self.customer = create_user(Role.CUSTOMER, username="paycust", email="paycust@example.com")
        login(self.client, "paycust")
        self.order_id = checkout_one_order(self.client, self.product)

    def test_initiate_payment_matches_order_total(self):
        response = self.client.post(reverse("payment-initiate"),
                                     {"order_id": self.order_id, "method": "BANK_TRANSFER"}, format="json")
        self.assertEqual(response.status_code, 201)
        payment = Payment.objects.get(order_id=self.order_id)
        order = Order.objects.get(id=self.order_id)
        self.assertEqual(payment.amount, order.total)
        self.assertEqual(payment.status, PaymentStatus.PENDING)

    def test_cannot_initiate_duplicate_pending_payment(self):
        self.client.post(reverse("payment-initiate"),
                          {"order_id": self.order_id, "method": "BANK_TRANSFER"}, format="json")
        response = self.client.post(reverse("payment-initiate"),
                                     {"order_id": self.order_id, "method": "BANK_TRANSFER"}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_cannot_initiate_payment_for_other_customers_order(self):
        create_user(Role.CUSTOMER, username="paycust2", email="paycust2@example.com")
        login(self.client, "paycust2")
        response = self.client.post(reverse("payment-initiate"),
                                     {"order_id": self.order_id, "method": "BANK_TRANSFER"}, format="json")
        self.assertEqual(response.status_code, 404)


class ReviewPaymentTests(APITestCase):
    def setUp(self):
        self.seller, self.product = make_paid_setup()
        self.customer = create_user(Role.CUSTOMER, username="revcust", email="revcust@example.com")
        self.admin = create_user(Role.ADMIN, username="revadmin", email="revadmin@example.com")

        login(self.client, "revcust")
        order_id = checkout_one_order(self.client, self.product)
        init = self.client.post(reverse("payment-initiate"),
                                 {"order_id": order_id, "method": "BANK_TRANSFER"}, format="json")
        self.payment_id = init.json()["data"]["id"]

    def test_customer_forbidden_from_admin_payments(self):
        login(self.client, "revcust")
        response = self.client.get(reverse("admin-payments"))
        self.assertEqual(response.status_code, 403)

    def test_admin_can_confirm_payment(self):
        login(self.client, "revadmin")
        response = self.client.post(reverse("payment-review", args=[self.payment_id]),
                                     {"action": "CONFIRM", "note": "Received"}, format="json")
        self.assertEqual(response.status_code, 200)

        payment = Payment.objects.get(id=self.payment_id)
        self.assertEqual(payment.status, PaymentStatus.CONFIRMED)
        self.assertEqual(payment.confirmed_by, self.admin)
        self.assertTrue(payment.audit_logs.filter(to_status=PaymentStatus.CONFIRMED).exists())

    def test_cannot_review_already_reviewed_payment(self):
        login(self.client, "revadmin")
        self.client.post(reverse("payment-review", args=[self.payment_id]), {"action": "CONFIRM"}, format="json")
        response = self.client.post(reverse("payment-review", args=[self.payment_id]),
                                     {"action": "CONFIRM"}, format="json")
        self.assertEqual(response.status_code, 400)


class ProofOfPaymentTests(APITestCase):
    def setUp(self):
        self.seller, self.product = make_paid_setup()
        self.customer = create_user(Role.CUSTOMER, username="proofcust", email="proofcust@example.com")
        login(self.client, "proofcust")
        order_id = checkout_one_order(self.client, self.product)
        init = self.client.post(reverse("payment-initiate"),
                                 {"order_id": order_id, "method": "BANK_TRANSFER"}, format="json")
        self.payment_id = init.json()["data"]["id"]

    def test_upload_valid_image_proof(self):
        response = self.client.post(reverse("payment-upload-proof", args=[self.payment_id]),
                                     {"proof": make_test_image()}, format="multipart")
        self.assertEqual(response.status_code, 200)
        payment = Payment.objects.get(id=self.payment_id)
        self.assertTrue(bool(payment.proof_of_payment))

    def test_rejects_non_image_file(self):
        bad_file = SimpleUploadedFile("proof.txt", b"not an image", content_type="text/plain")
        response = self.client.post(reverse("payment-upload-proof", args=[self.payment_id]),
                                     {"proof": bad_file}, format="multipart")
        self.assertEqual(response.status_code, 400)

    def test_cannot_upload_proof_for_others_payment(self):
        create_user(Role.CUSTOMER, username="proofcust2", email="proofcust2@example.com")
        login(self.client, "proofcust2")
        response = self.client.post(reverse("payment-upload-proof", args=[self.payment_id]),
                                     {"proof": make_test_image()}, format="multipart")
        self.assertEqual(response.status_code, 404)