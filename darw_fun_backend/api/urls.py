from django.urls import path
from .views import UserSignupView, UserLookupView, DrawingsView, DrawingDetailView, DrawingCompleteView, AchievementsView, AchievementUnlockView, ProcessImageView, CategoryView, DrawingLevelView, ColoringView ,DeleteUserView, DeleteCategoryView, DeleteDrawingView
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView



urlpatterns = [
    path('user/signup/', UserSignupView.as_view(), name='user-signup'),
    path('user/lookup/', UserLookupView.as_view(), name='user-lookup'),
    path('drawings/', DrawingsView.as_view(), name='drawings-all'),
    path('drawings/<int:id>/', DrawingDetailView.as_view(), name='drawing-detail'),
    path('drawings/<int:id>/complete/', DrawingCompleteView.as_view(), name='drawing-complete'),
    path('achievements/', AchievementsView.as_view(), name='achievements'),
    path('achievements/unlock/', AchievementUnlockView.as_view(), name='achievement-unlock'),
    path('process-image/', ProcessImageView.as_view(), name='process-image'),
    path('categories/', CategoryView.as_view(), name='categories'),
    path('categories/<int:category_id>/drawings/', DrawingsView.as_view(), name='category-drawings'),
    path('categories/<int:category_id>/drawings/<int:drawing_id>/', DrawingLevelView.as_view(), name='drawing-level'),
    path('coloring/<int:drawing_id>/', ColoringView.as_view(), name='coloring'), 
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    
    path('user/<int:user_id>/delete/', DeleteUserView.as_view(), name='user-delete'),
    path('categories/<int:category_id>/delete/', DeleteCategoryView.as_view(), name='category-delete'),
    path('categories/', CategoryView.as_view(), name='categories-list-create'),
    path('drawings/<int:drawing_id>/delete/', DeleteDrawingView.as_view(), name='drawing-delete'),
]
