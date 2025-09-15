from rest_framework import serializers
from .models import Drawing, User, Achievement, Category

class DrawingSerializer(serializers.ModelSerializer):
    levels = serializers.SerializerMethodField()
    progress = serializers.JSONField()
    is_completed = serializers.JSONField()

    class Meta:
        model = Drawing
        fields = ['id', 'title', 'category', 'input_image', 'outline_image', 'current_dot', 'progress', 'is_completed', 'levels']

    def get_levels(self, obj):
        return {
            'draw': [
                {
                    'difficulty': 'Easy',
                    'preview': obj.easy_draw_preview.url if obj.easy_draw_preview else '',
                    'coordinates': obj.easy_coordinates
                },
                {
                    'difficulty': 'Medium',
                    'preview': obj.medium_draw_preview.url if obj.medium_draw_preview else '',
                    'coordinates': obj.medium_coordinates
                },
                {
                    'difficulty': 'Hard',
                    'preview': obj.hard_draw_preview.url if obj.hard_draw_preview else '',
                    'coordinates': obj.hard_coordinates
                }
            ],
            'learn': [
                {
                    'difficulty': 'Easy',
                    'preview': obj.easy_learn_preview.url if obj.easy_learn_preview else '',
                    'coordinates': obj.easy_learn_coordinates
                },
                {
                    'difficulty': 'Medium',
                    'preview': obj.medium_learn_preview.url if obj.medium_learn_preview else '',
                    'coordinates': obj.medium_learn_coordinates
                },
                {
                    'difficulty': 'Hard',
                    'preview': obj.hard_learn_preview.url if obj.hard_learn_preview else '',
                    'coordinates': obj.hard_learn_coordinates
                }
            ]
        }

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'age', 'parent_email', 'stars']

class AchievementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Achievement
        fields = ['id', 'name', 'icon_path']

class CategorySerializer(serializers.ModelSerializer):
    drawing_count = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ['id', 'name', 'image', 'drawing_count']

    def get_drawing_count(self, obj):
        return obj.drawings.count() if hasattr(obj, 'drawings') else 0
    