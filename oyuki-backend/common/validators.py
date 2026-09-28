import os
from django.core.exceptions import ValidationError

ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
MAX_IMAGE_SIZE_MB = 5


def validate_image_file(file):
    ext = os.path.splitext(file.name)[1].lower()
    if ext not in ALLOWED_IMAGE_EXTENSIONS:
        raise ValidationError(f"Unsupported file type '{ext}'. Allowed: {', '.join(ALLOWED_IMAGE_EXTENSIONS)}")
    if file.size > MAX_IMAGE_SIZE_MB * 1024 * 1024:
        raise ValidationError(f"File too large. Max size is {MAX_IMAGE_SIZE_MB}MB.")


def validate_location_chain(state_id=None, lga_id=None, market_id=None):
    """Confirms LGA actually belongs to State, and Market actually belongs to LGA.
    Call this anywhere a form submits more than one location field at once."""
    from marketplace.models import LGA, Market

    if lga_id and state_id and not LGA.objects.filter(id=lga_id, state_id=state_id).exists():
        raise ValidationError("Selected LGA does not belong to the selected State.")
    if market_id and lga_id and not Market.objects.filter(id=market_id, lga_id=lga_id).exists():
        raise ValidationError("Selected Market does not belong to the selected LGA.")