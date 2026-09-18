from rest_framework.permissions import BasePermission
from .models import Role


class HasRole(BasePermission):
    """Base class — subclass with `required_role` set, or use the factory below."""
    required_role = None

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role == self.required_role
        )


def role_required(role: str):
    """Factory: role_required(Role.ADMIN) returns a ready-to-use permission class."""
    return type(f"Is{role.title().replace('_', '')}", (HasRole,), {"required_role": role})


IsCustomer = role_required(Role.CUSTOMER)
IsSeller = role_required(Role.SELLER)
IsAdmin = role_required(Role.ADMIN)
IsAccountOfficer = role_required(Role.ACCOUNT_OFFICER)
IsLogisticsAdmin = role_required(Role.LOGISTICS_ADMIN)
IsRider = role_required(Role.RIDER)
IsMarketAgent = role_required(Role.MARKET_AGENT)
IsMarketSupervisor = role_required(Role.MARKET_SUPERVISOR)
IsMarketer = role_required(Role.MARKETER)