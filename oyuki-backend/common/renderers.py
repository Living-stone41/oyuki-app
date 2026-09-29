from rest_framework.renderers import JSONRenderer


def _is_already_enveloped(data):
    return isinstance(data, dict) and data.get("status") in ("success", "error") and "message" in data


class EnvelopeJSONRenderer(JSONRenderer):
    def render(self, data, accepted_media_type=None, renderer_context=None):
        response = renderer_context.get("response") if renderer_context else None
        status_code = response.status_code if response else 200

        if data is not None and not _is_already_enveloped(data):
            data = {
                "status": "success" if status_code < 400 else "error",
                "message": "Success" if status_code < 400 else "Request failed",
                "data": data,
            }
        return super().render(data, accepted_media_type, renderer_context)