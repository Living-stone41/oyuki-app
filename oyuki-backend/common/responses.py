from rest_framework.response import Response


def success_response(data=None, message="Success", status_code=200):
    return Response(
        {
            "status": "success" if status_code < 400 else "error",
            "message": message,
            "data": data,
        },
        status=status_code,
    )