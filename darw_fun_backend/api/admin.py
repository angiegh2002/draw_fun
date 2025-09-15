from django.contrib import admin
from .models import User, Drawing, Achievement, Category

admin.site.register(User)
admin.site.register(Drawing)
admin.site.register(Achievement)
admin.site.register(Category)