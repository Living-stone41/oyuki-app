import hashlib
from django.utils import timezone
from datetime import timedelta
from .models import OTP


def hash_code(code: str) -> str:
    return hashlib.sha256(code.encode()).hexdigest()


def create_otp(user, purpose: str, ttl_minutes: int = 10) -> str:
    code = OTP.generate_code()
    OTP.objects.create(
        user=user,
        code_hash=hash_code(code),
        purpose=purpose,
        expires_at=timezone.now() + timedelta(minutes=ttl_minutes),
    )
    return code  # plain code goes out via email; only the hash is stored


def verify_otp(user, code: str, purpose: str) -> tuple[bool, str]:
    otp = OTP.objects.filter(user=user, purpose=purpose).order_by("-created_at").first()
    if not otp:
        return False, "No OTP found."
    if otp.is_expired():
        return False, "OTP expired."
    if otp.attempts >= 5:
        return False, "Too many attempts."

    otp.attempts += 1
    otp.save(update_fields=["attempts"])

    if otp.code_hash != hash_code(code):
        return False, "Incorrect code."

    otp.delete()
    return True, "OK"