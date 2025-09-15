
import cv2
import numpy as np
import os
import logging
from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Drawing, User, Achievement, Category
from .serializers import DrawingSerializer, UserSerializer, AchievementSerializer, CategorySerializer
from Dot2Dot import DotToDotGenerator, DifficultyLevel
from rest_framework.parsers import MultiPartParser, FormParser

class UserSignupView(APIView):
    def post(self, request):
        required_fields = {'username', 'age'}
        if not all(field in request.data for field in required_fields):
            return Response({"error": "Username and age are required"}, status=status.HTTP_400_BAD_REQUEST)
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserView(APIView):
    def get(self, request, user_id):
        try:
            user = User.objects.get(id=user_id)
            serializer = UserSerializer(user)
            return Response(serializer.data)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

class UserLookupView(APIView):
    def get(self, request):
        username = request.query_params.get('username')
        age = request.query_params.get('age')

        if not username and not age:
            users = User.objects.all()
            serializer = UserSerializer(users, many=True)
            return Response(serializer.data) 

        if username and age:
            try:
                age = int(age)
                users = User.objects.filter(username=username, age=age)
                if not users.exists():
                    return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
               
                if users.count() > 1:
                    serializer = UserSerializer(users, many=True)
                    return Response(serializer.data)
                serializer = UserSerializer(users.first()) 
                return Response(serializer.data)
            except ValueError:
                return Response({"error": "Invalid age"}, status=status.HTTP_400_BAD_REQUEST)

        return Response({"error": "Username and age are required for specific lookup"}, status=status.HTTP_400_BAD_REQUEST)
# class UserLookupView(APIView):
#     def get(self, request):
#         username = request.query_params.get('username')
#         age = request.query_params.get('age')
#         if not username or not age:
#             return Response({"error": "Username and age are required"}, status=status.HTTP_400_BAD_REQUEST)
#         try:
#             age = int(age)
#             users = User.objects.filter(username=username, age=age)
#             if not users.exists():
#                 return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
#             if users.count() > 1:
#                 return Response({"error": "Multiple users found"}, status=status.HTTP_400_BAD_REQUEST)
#             serializer = UserSerializer(users[0])
#             return Response(serializer.data)
#         except ValueError:
#             return Response({"error": "Invalid age"}, status=status.HTTP_400_BAD_REQUEST)

class CategoryView(APIView):

    parser_classes = (MultiPartParser, FormParser)
    # def get(self, request):
    #     categories = Category.objects.all()
    #     if not categories.exists():
    #         return Response([])
    #     serializer = CategorySerializer(categories, many=True)
    #     return Response(serializer.data)
    
    def get(self, request):
        categories = Category.objects.all()
        if not categories.exists():
            return Response([])
        serializer = CategorySerializer(categories, many=True)
  
        data = serializer.data
        for item in data:
            try:
                cat_id = item['id'] 
                item['drawing_count'] = Drawing.objects.filter(category_id=cat_id).count()
            except:
                item['drawing_count'] = 0
        return Response(data)

    def post(self, request):
        
        serializer = CategorySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        # تحسين رسالة الخطأ
        return Response({"error": "Invalid data", "details": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

class DrawingsView(APIView):
    def get(self, request, category_id=None):
        drawings = Drawing.objects.all()
        if category_id:
            drawings = drawings.filter(category_id=category_id)
        class SimpleDrawingSerializer(DrawingSerializer):
            class Meta(DrawingSerializer.Meta):
                fields = ['id', 'title', 'category', 'input_image', 'current_dot']
        serializer = SimpleDrawingSerializer(drawings, many=True)
        return Response(serializer.data)

class DrawingDetailView(APIView):
    def get(self, request, id):
        try:
            drawing = Drawing.objects.get(id=id)
            serializer = DrawingSerializer(drawing)
            data = serializer.data
            level = request.query_params.get('level', 'easy').lower()
            mode = request.query_params.get('mode', 'draw').lower()
            if mode not in ['learn', 'draw']:
                return Response({"error": "Invalid mode, use 'learn' or 'draw'"}, status=status.HTTP_400_BAD_REQUEST)
            if level not in ['easy', 'medium', 'hard']:
                return Response({"error": "Invalid level, use 'easy', 'medium', or 'hard'"}, status=status.HTTP_400_BAD_REQUEST)
            
            preview_field = f'{level}_{mode}_preview'
            coord_field = f'{level}_coordinates' if mode == 'draw' else f'{level}_learn_coordinates'
            coordinates = getattr(drawing, coord_field)
            if not coordinates:
                return Response({"error": f"No coordinates available for {level} {mode}"}, status=status.HTTP_400_BAD_REQUEST)
            
            total_dots = len(coordinates) if mode == 'draw' else sum(len(contour['dots']) for contour in coordinates)
            is_completed = drawing.is_completed.get(level, {}).get(mode, False) if drawing.is_completed else False
            
            if mode == 'learn':
                progress = drawing.progress.get(level, {}).get(mode, 0) if drawing.progress else 0
                if progress >= total_dots:
                    return Response({"error": "No more dots"}, status=status.HTTP_400_BAD_REQUEST)
                
                current_contour = None
                current_dot_idx = progress
                for contour in coordinates:
                    if current_dot_idx < len(contour['dots']):
                        current_contour = contour
                        break
                    current_dot_idx -= len(contour['dots'])
                if not current_contour:
                    return Response({"error": "Invalid contour data"}, status=status.HTTP_400_BAD_REQUEST)
                
                current_dot = current_contour['dots'][current_dot_idx]
                next_dot_idx = current_dot_idx + 1
                next_dot = current_contour['dots'][next_dot_idx] if next_dot_idx < len(current_contour['dots']) else None
                dot_data = {
                    'image_url': getattr(drawing, preview_field).url if getattr(drawing, preview_field) else '',
                    'total_dots': total_dots,
                    'current_index': progress,
                    'mode': mode,
                    'current_dot': current_dot,
                    'next_dot': next_dot,
                    'contour_id': current_contour['contour_id'],
                    'close_contour': current_contour['close_contour'],
                    'is_completed': is_completed
                }
                
                if progress > 0 and current_dot['number'] != current_contour['dots'][current_dot_idx-1]['number'] + 1:
                    dot_data['message'] = "Error: Incorrect dot connection. Please connect to the next number."
                else:
                    dot_data['message'] = "Great job! Keep connecting the dots."
                
                
                drawing.progress.setdefault(level, {})
                drawing.progress[level][mode] = progress + 1
                if progress + 1 >= total_dots:
                    drawing.is_completed.setdefault(level, {})
                    drawing.is_completed[level][mode] = True
            else:
                
                current = drawing.current_dot
                if current >= total_dots:
                    return Response({"error": "No more dots"}, status=status.HTTP_400_BAD_REQUEST)
                
                current_dot = coordinates[current]
                next_dot = coordinates[current + 1] if current + 1 < total_dots else None
                dot_data = {
                    'image_url': getattr(drawing, preview_field).url if getattr(drawing, preview_field) else '',
                    'total_dots': total_dots,
                    'current_index': current,
                    'mode': mode,
                    'current_dot': current_dot,
                    'next_dot': next_dot,
                    'is_completed': is_completed
                }
                
                drawing.current_dot = current + 1
                if current + 1 >= total_dots:
                    drawing.is_completed.setdefault(level, {})
                    drawing.is_completed[level][mode] = True
            
            drawing.save()
            return Response(dot_data)
        except Drawing.DoesNotExist:
            return Response({"error": "Drawing not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, id):
        try:
            drawing = Drawing.objects.get(id=id)
            level = request.query_params.get('level', 'easy').lower()
            mode = request.query_params.get('mode', 'draw').lower()
            if mode not in ['learn', 'draw']:
                return Response({"error": "Invalid mode, use 'learn' or 'draw'"}, status=status.HTTP_400_BAD_REQUEST)
            if level not in ['easy', 'medium', 'hard']:
                return Response({"error": "Invalid level, use 'easy', 'medium', or 'hard'"}, status=status.HTTP_400_BAD_REQUEST)
            
            coord_field = f'{level}_coordinates' if mode == 'draw' else f'{level}_learn_coordinates'
            coordinates = getattr(drawing, coord_field)
            if not coordinates:
                return Response({"error": f"No coordinates available for {level} {mode}"}, status=status.HTTP_400_BAD_REQUEST)
            
            total_dots = len(coordinates) if mode == 'draw' else sum(len(contour['dots']) for contour in coordinates)
            is_completed = drawing.is_completed.get(level, {}).get(mode, False) if drawing.is_completed else False
            
            if mode == 'learn':
                progress = drawing.progress.get(level, {}).get(mode, 0) if drawing.progress else 0
                if progress >= total_dots:
                    return Response({"message": "Drawing complete"}, status=status.HTTP_200_OK)
                
                current_contour = None
                current_dot_idx = progress
                for contour in coordinates:
                    if current_dot_idx < len(contour['dots']):
                        current_contour = contour
                        break
                    current_dot_idx -= len(contour['dots'])
                if not current_contour:
                    return Response({"error": "Invalid contour data"}, status=status.HTTP_400_BAD_REQUEST)
                
                current_dot = current_contour['dots'][current_dot_idx]
                next_dot_idx = current_dot_idx + 1
                next_dot = current_contour['dots'][next_dot_idx] if next_dot_idx < len(current_contour['dots']) else None
                dot_data = {
                    'image_url': getattr(drawing, f'{level}_{mode}_preview').url if getattr(drawing, f'{level}_{mode}_preview') else '',
                    'total_dots': total_dots,
                    'current_index': progress,
                    'mode': mode,
                    'current_dot': current_dot,
                    'next_dot': next_dot,
                    'contour_id': current_contour['contour_id'],
                    'close_contour': current_contour['close_contour'],
                    'is_completed': is_completed
                }
                
                if progress > 0 and current_dot['number'] != current_contour['dots'][current_dot_idx-1]['number'] + 1:
                    dot_data['message'] = "Error: Incorrect dot connection. Please connect to the next number."
                else:
                    dot_data['message'] = "Great job! Keep connecting the dots."
                
                drawing.progress.setdefault(level, {})
                drawing.progress[level][mode] = progress + 1
                if progress + 1 >= total_dots:
                    drawing.is_completed.setdefault(level, {})
                    drawing.is_completed[level][mode] = True
            else:
                current = drawing.current_dot
                if current >= total_dots:
                    return Response({"message": "Drawing complete"}, status=status.HTTP_200_OK)
                
                current_dot = coordinates[current]
                next_dot = coordinates[current + 1] if current + 1 < total_dots else None
                dot_data = {
                    'image_url': getattr(drawing, f'{level}_{mode}_preview').url if getattr(drawing, f'{level}_{mode}_preview') else '',
                    'total_dots': total_dots,
                    'current_index': current,
                    'mode': mode,
                    'current_dot': current_dot,
                    'next_dot': next_dot,
                    'is_completed': is_completed
                }
                
                drawing.current_dot = current + 1
                if current + 1 >= total_dots:
                    drawing.is_completed.setdefault(level, {})
                    drawing.is_completed[level][mode] = True
            
            drawing.save()
            return Response(dot_data, status=status.HTTP_200_OK)
        except Drawing.DoesNotExist:
            return Response({"error": "Drawing not found"}, status=status.HTTP_404_NOT_FOUND)

class DrawingLevelView(APIView):
    def get(self, request, category_id, drawing_id):
        try:
            drawing = Drawing.objects.get(id=drawing_id, category_id=category_id)
            serializer = DrawingSerializer(drawing)
            data = serializer.data
            level = request.query_params.get('level', 'easy').lower()
            mode = request.query_params.get('mode', 'draw').lower()
            logger = logging.getLogger(__name__)
            logger.debug(f"Fetching drawing {drawing_id}, mode={mode}, level={level}, easy_learn_coordinates={drawing.easy_learn_coordinates}")
            
            if mode not in ['learn', 'draw']:
                return Response({"error": "Invalid mode, use 'learn' or 'draw'"}, status=status.HTTP_400_BAD_REQUEST)
            if level not in ['easy', 'medium', 'hard']:
                return Response({"error": "Invalid level, use 'easy', 'medium', or 'hard'"}, status=status.HTTP_400_BAD_REQUEST)
            
            preview_field = f'{level}_{mode}_preview'
            coord_field = f'{level}_coordinates' if mode == 'draw' else f'{level}_learn_coordinates'
            coordinates = getattr(drawing, coord_field)
            if not coordinates:
                logger.error(f"No coordinates in {coord_field} for drawing {drawing_id}")
                return Response({"error": f"No coordinates available for {level} {mode}"}, status=status.HTTP_400_BAD_REQUEST)
            
            total_dots = len(coordinates) if mode == 'draw' else sum(len(contour['dots']) for contour in coordinates)
            is_completed = drawing.is_completed.get(level, {}).get(mode, False) if drawing.is_completed else False
            
            if request.query_params.get('reset', 'false').lower() == 'true':
                if mode == 'learn':
                    drawing.progress.setdefault(level, {})
                    drawing.progress[level][mode] = 0
                else:
                    drawing.current_dot = 0
                drawing.is_completed.setdefault(level, {})
                drawing.is_completed[level][mode] = False
            
            if mode == 'learn':
                progress = drawing.progress.get(level, {}).get(mode, 0) if drawing.progress else 0
                if progress >= total_dots:
                    logger.debug(f"Drawing {drawing_id} completed for {level} learn")
                    return Response({"error": "No more dots"}, status=status.HTTP_400_BAD_REQUEST)
                
                current_contour = None
                current_dot_idx = progress
                for contour in coordinates:
                    if current_dot_idx < len(contour['dots']):
                        current_contour = contour
                        break
                    current_dot_idx -= len(contour['dots'])
                if not current_contour:
                    logger.error(f"Invalid contour data for {level} learn in drawing {drawing_id}")
                    return Response({"error": "Invalid contour data"}, status=status.HTTP_400_BAD_REQUEST)
                
                current_dot = current_contour['dots'][current_dot_idx]
                next_dot_idx = current_dot_idx + 1
                next_dot = current_contour['dots'][next_dot_idx] if next_dot_idx < len(current_contour['dots']) else None
                dot_data = {
                    'image_url': getattr(drawing, preview_field).url if getattr(drawing, preview_field) else '',
                    'total_dots': total_dots,
                    'current_index': progress,
                    'mode': mode,
                    'current_dot': current_dot,
                    'next_dot': next_dot,
                    'contour_id': current_contour['contour_id'],
                    'close_contour': current_contour['close_contour'],
                    'is_completed': is_completed
                }
                
                if progress > 0 and current_dot['number'] != current_contour['dots'][current_dot_idx-1]['number'] + 1:
                    dot_data['message'] = "Error: Incorrect dot connection. Please connect to the next number."
                else:
                    dot_data['message'] = "Great job! Keep connecting the dots."
                
                drawing.progress.setdefault(level, {})
                drawing.progress[level][mode] = progress + 1
                if progress + 1 >= total_dots:
                    drawing.is_completed.setdefault(level, {})
                    drawing.is_completed[level][mode] = True
            else:
                current = drawing.current_dot
                if current >= total_dots:
                    logger.debug(f"Drawing {drawing_id} completed for {level} draw")
                    return Response({"error": "No more dots"}, status=status.HTTP_400_BAD_REQUEST)
                
                current_dot = coordinates[current]
                next_dot = coordinates[current + 1] if current + 1 < total_dots else None
                dot_data = {
                    'image_url': getattr(drawing, preview_field).url if getattr(drawing, preview_field) else '',
                    'total_dots': total_dots,
                    'current_index': current,
                    'mode': mode,
                    'current_dot': current_dot,
                    'next_dot': next_dot,
                    'is_completed': is_completed
                }
                
                drawing.current_dot = current + 1
                if current + 1 >= total_dots:
                    drawing.is_completed.setdefault(level, {})
                    drawing.is_completed[level][mode] = True
            
            drawing.save()
            logger.debug(f"Updated drawing {drawing_id}: progress={drawing.progress}, is_completed={drawing.is_completed}")
            return Response(dot_data)
        except Drawing.DoesNotExist:
            logger.error(f"Drawing {drawing_id} not found")
            return Response({"error": "Drawing not found"}, status=status.HTTP_404_NOT_FOUND)

class DrawingCompleteView(APIView):
    def post(self, request, id):
        try:
            drawing = Drawing.objects.get(id=id)
            user_id = request.data.get('user_id')
            user = User.objects.get(id=user_id)
            level = request.query_params.get('level', 'easy').lower()
            mode = request.query_params.get('mode', 'draw').lower()
            if mode not in ['learn', 'draw']:
                return Response({"error": "Invalid mode, use 'learn' or 'draw'"}, status=status.HTTP_400_BAD_REQUEST)
            if level not in ['easy', 'medium', 'hard']:
                return Response({"error": "Invalid level, use 'easy', 'medium', or 'hard'"}, status=status.HTTP_400_BAD_REQUEST)
            
            coord_field = f'{level}_coordinates' if mode == 'draw' else f'{level}_learn_coordinates'
            coordinates = getattr(drawing, coord_field)
            if not coordinates:
                return Response({"error": f"No coordinates available for {level} {mode}"}, status=status.HTTP_400_BAD_REQUEST)
            
            total_dots = len(coordinates) if mode == 'draw' else sum(len(contour['dots']) for contour in coordinates)
            if mode == 'learn':
                progress = drawing.progress.get(level, {}).get(mode, 0) if drawing.progress else 0
                if progress >= total_dots:
                    stars = request.data.get('stars', user.stars)
                    user.stars = stars
                    user.save()
                    return Response({"message": f"{mode.capitalize()} drawing completed", "stars": stars})
            else:
                if drawing.current_dot >= total_dots:
                    stars = request.data.get('stars', user.stars)
                    user.stars = stars
                    user.save()
                    return Response({"message": f"{mode.capitalize()} drawing completed", "stars": stars})
            
            return Response({"error": "Drawing not yet complete"}, status=status.HTTP_400_BAD_REQUEST)
        except Drawing.DoesNotExist:
            return Response({"error": "Drawing not found"}, status=status.HTTP_404_NOT_FOUND)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

class ProcessImageView(APIView):
    def post(self, request):
        image_file = request.FILES.get('image')
        category_id = request.data.get('category_id')
        if not image_file or not image_file.name.lower().endswith(('.png', '.jpg', '.jpeg')) or not category_id:
            return Response({"error": "Invalid or no image/category provided"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            temp_path = default_storage.save('temp_upload.png', ContentFile(image_file.read()))
            temp_full_path = os.path.join(default_storage.location, temp_path)

            generator = DotToDotGenerator()
            original, gray = generator.load_and_preprocess_image(temp_full_path)
            if original is None:
                default_storage.delete(temp_path)
                return Response({"error": "Image processing failed"}, status=status.HTTP_400_BAD_REQUEST)
            
            category = Category.objects.get(id=category_id)
            drawing = Drawing.objects.create(
                title=image_file.name.split('.')[0],
                category=category,
                progress={},
                is_completed={}
            )
            image_file.seek(0)
            drawing.input_image.save(f'drawings/input/{drawing.title}_input.png', ContentFile(image_file.read()), save=False)

            outer = generator.detect_outer_contours(gray)
            inner = generator.detect_inner_features(gray)
            settings = generator.calculate_dynamic_settings(original.shape, DifficultyLevel.MEDIUM)
            final_contours = generator.combine_and_filter_contours(outer, inner, settings)
            
            line_img = generator.create_line_image(original.shape, final_contours)
            _, line_img_encoded = cv2.imencode('.png', line_img)
            drawing.outline_image.save(f'drawings/lines/{drawing.title}_lines.png', ContentFile(line_img_encoded.tobytes()), save=False)

            for difficulty in [DifficultyLevel.EASY, DifficultyLevel.MEDIUM, DifficultyLevel.HARD]:
                dots = generator.generate_dots_from_contours(final_contours, difficulty, original.shape)
                if dots:
                    img = generator.create_dot_image(original, dots, difficulty, show_numbers=False)
                    _, img_encoded = cv2.imencode('.png', img)
                    draw_field = f'{difficulty.value}_draw_preview'
                    draw_coord_field = f'{difficulty.value}_coordinates'
                    setattr(drawing, draw_field, ContentFile(img_encoded.tobytes(), name=f'drawings/draw/draw_{drawing.title}_{difficulty.value}.png'))
                    setattr(drawing, draw_coord_field, [{'x': d['x'], 'y': d['y']} for d in dots])

            outer_contours = [contour for contour in outer if settings['min_contour_area'] <= cv2.contourArea(contour) <= settings['max_contour_area']]
            for difficulty in [DifficultyLevel.EASY, DifficultyLevel.MEDIUM, DifficultyLevel.HARD]:
                dots = generator.generate_dots_from_contours(outer_contours, difficulty, original.shape)
                if dots:
                    img = generator.create_dot_image(original, dots, difficulty, show_numbers=True)
                    _, img_encoded = cv2.imencode('.png', img)
                    learn_field = f'{difficulty.value}_learn_preview'
                    learn_coord_field = f'{difficulty.value}_learn_coordinates'
                    setattr(drawing, learn_field, ContentFile(img_encoded.tobytes(), name=f'drawings/learn/learn_{drawing.title}_{difficulty.value}.png'))
                    contours_dots = {}
                    for dot in dots:
                        contour_id = dot['contour_id']
                        if contour_id not in contours_dots:
                            contours_dots[contour_id] = []
                        contours_dots[contour_id].append({
                            'number': dot['number'],
                            'x': dot['x'],
                            'y': dot['y'],
                            'position_ratio': dot['position_ratio']
                        })
                    setattr(drawing, learn_coord_field, [
                        {
                            'contour_id': contour_id,
                            'dots': dots,
                            'close_contour': True
                        } for contour_id, dots in contours_dots.items()
                    ])

            drawing.save()
            default_storage.delete(temp_path)
            serializer = DrawingSerializer(drawing)
            return Response({
                "message": "Image processed",
                "drawing_id": drawing.id,
                "data": serializer.data
            }, status=status.HTTP_201_CREATED)
        except Category.DoesNotExist:
            default_storage.delete(temp_path)
            return Response({"error": "Category not found"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            if 'temp_path' in locals():
                default_storage.delete(temp_path)
            logger = logging.getLogger(__name__)
            logger.error(f"Processing error: {str(e)}")
            return Response({"error": f"Processing error: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        
class ColoringView(APIView):
    def get(self, request, drawing_id):
        try:
            drawing = Drawing.objects.get(id=drawing_id)
            if not drawing.outline_image:
                return Response({"error": "No outline image available"}, status=status.HTTP_400_BAD_REQUEST)
            return Response({
                "image_url": drawing.outline_image.url,
                "title": drawing.title,
                "bounding_box": {
                    "width": drawing.outline_image.width,
                    "height": drawing.outline_image.height
                }
            })
        except Drawing.DoesNotExist:
            return Response({"error": "Drawing not found"}, status=status.HTTP_404_NOT_FOUND)

class AchievementsView(APIView):
    def get(self, request):
        achievements = Achievement.objects.all()
        serializer = AchievementSerializer(achievements, many=True)
        return Response(serializer.data)

class AchievementUnlockView(APIView):
    def post(self, request):
        achievement_id = request.data.get('achievement_id')
        user_id = request.data.get('user_id')
        try:
            achievement = Achievement.objects.get(id=achievement_id)
            user = User.objects.get(id=user_id)
            achievement.earned_by.add(user)
            return Response({"message": f"Achievement {achievement.name} unlocked"})
        except Achievement.DoesNotExist:
            return Response({"error": "Achievement not found"}, status=status.HTTP_404_NOT_FOUND)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)


class DeleteUserView(APIView):
    def delete(self, request, user_id):
        try:
            user = User.objects.get(id=user_id)
            user.delete()
            return Response({"message": "User deleted"}, status=status.HTTP_204_NO_CONTENT)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

class DeleteCategoryView(APIView):
    def delete(self, request, category_id):
        try:
            category = Category.objects.get(id=category_id)
            category.delete()
            return Response({"message": "Category deleted"}, status=status.HTTP_204_NO_CONTENT)
        except Category.DoesNotExist:
            return Response({"error": "Category not found"}, status=status.HTTP_404_NOT_FOUND)

class DeleteDrawingView(APIView):
    def delete(self, request, drawing_id):
        try:
            drawing = Drawing.objects.get(id=drawing_id)
            drawing.delete()
            return Response({"message": "Drawing deleted"}, status=status.HTTP_204_NO_CONTENT)
        except Drawing.DoesNotExist:
            return Response({"error": "Drawing not found"}, status=status.HTTP_404_NOT_FOUND)
        
