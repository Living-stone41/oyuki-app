from django.contrib import admin
from .models import State, LGA, Market, Category, Product, ProductImage, Wishlist

admin.site.register(State)
admin.site.register(LGA)
admin.site.register(Market)
admin.site.register(Category)
admin.site.register(Product)
admin.site.register(ProductImage)
admin.site.register(Wishlist)