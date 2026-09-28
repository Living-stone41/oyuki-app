import uuid
import os


def safe_upload_path(filename, subfolder):
    ext = os.path.splitext(filename)[1].lower()
    return f"{subfolder}/{uuid.uuid4().hex}{ext}"


def product_image_path(instance, filename):
    return safe_upload_path(filename, "products")


def payment_proof_path(instance, filename):
    return safe_upload_path(filename, "payment_proofs")