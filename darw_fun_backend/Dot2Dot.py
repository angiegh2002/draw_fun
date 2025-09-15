"""Two Types(Learn, Draw) Three levels each, outline Lines"""

import cv2
import numpy as np
import os
import json
import math
from typing import List, Tuple, Dict, Any
from enum import Enum
import time
class DifficultyLevel(Enum):
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"

class DotToDotGenerator:
    def __init__(self):
        self.input_folder = "input_images"
        self.output_folder = "output_images"
        os.makedirs(self.input_folder, exist_ok=True)
        os.makedirs(self.output_folder, exist_ok=True)

        self.base_settings = {
            DifficultyLevel.EASY: {
                'dot_spacing_ratio': 0.08,
                'dot_size_ratio': 0.002,
                'image_transparency': 0.6,
                'show_image': True,
                'dot_density': 0.6,
                'number_font_scale_ratio': 0.0005,
                'number_thickness': 1,
                'min_contour_area_ratio': 0.03,
                'max_contour_area_ratio': 0.7
            },
            DifficultyLevel.MEDIUM: {
                'dot_spacing_ratio': 0.085,
                'dot_size_ratio': 0.0025,
                'image_transparency': 0.4,
                'show_image': True,
                'dot_density': 0.5,
                'number_font_scale_ratio': 0.00012,
                'number_thickness': 1,
                'min_contour_area_ratio': 0.003,
                'max_contour_area_ratio': 0.7
            },
            DifficultyLevel.HARD: {
                'dot_spacing_ratio': 0.09,
                'dot_size_ratio': 0.003,
                'image_transparency': 0.2,
                'show_image': True,
                'dot_density': 0.4,
                'number_font_scale_ratio': 0.00015,
                'number_thickness': 1,
                'min_contour_area_ratio': 0.003,
                'max_contour_area_ratio': 0.7
            }
        }

    def calculate_dynamic_settings(self, image_shape: Tuple[int, int], difficulty: DifficultyLevel) -> Dict[str, Any]:
        height, width = image_shape[:2]
        diagonal = math.sqrt(width ** 2 + height ** 2)
        image_area = width * height
        base = self.base_settings[difficulty]
        return {
            'dot_spacing': max(8, int(diagonal * base['dot_spacing_ratio'])),
            'dot_size': max(3, int(diagonal * base['dot_size_ratio'])),
            'image_transparency': base['image_transparency'],
            'show_image': base['show_image'],
            'dot_density': base['dot_density'],
            'number_font_scale': max(0.3, diagonal * base['number_font_scale_ratio']),
            'number_thickness': base['number_thickness'],
            'min_contour_area': int(image_area * base['min_contour_area_ratio']),
            'max_contour_area': int(image_area * base['max_contour_area_ratio']),
            'image_diagonal': diagonal,
            'image_area': image_area
        }

    def load_and_preprocess_image(self, image_path: str) -> Tuple[np.ndarray, np.ndarray]:
        try:
            original = cv2.imread(image_path)
            if original is None:
                raise ValueError(f"Could not load image: {image_path}")
            height, width = original.shape[:2]
            print(f"Original image size: {width}x{height}")
            max_dimension = max(height, width)
            target_size = 400
            if max_dimension > 1200:
                target_size = 800
            elif max_dimension > 800:
                target_size = 600
            elif max_dimension < 300:
                target_size = 400
            else:
                target_size = max_dimension
            if max_dimension != target_size:
                if width > height:
                    new_width = target_size
                    new_height = int(height * target_size / width)
                else:
                    new_height = target_size
                    new_width = int(width * target_size / height)
                original = cv2.resize(original, (new_width, new_height), interpolation=cv2.INTER_LANCZOS4)
                print(f"Resized to: {new_width}x{new_height}")
            gray = cv2.cvtColor(original, cv2.COLOR_BGR2GRAY)
            print(f"Processed image: {os.path.basename(image_path)} ({original.shape[1]}x{original.shape[0]})")
            return original, gray
        except Exception as e:
            print(f"Error loading image {image_path}: {str(e)}")
            return None, None

    def detect_outer_contours(self, gray_image: np.ndarray) -> List[np.ndarray]:
        try:
            _, binary1 = cv2.threshold(gray_image, 200, 255, cv2.THRESH_BINARY)
            binary1 = cv2.bitwise_not(binary1)
            binary2 = cv2.adaptiveThreshold(gray_image, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 15, 10)
            binary2 = cv2.bitwise_not(binary2)
            combined = cv2.bitwise_or(binary1, binary2)
            kernel = np.ones((3, 3), np.uint8)
            combined = cv2.morphologyEx(combined, cv2.MORPH_CLOSE, kernel)
            combined = cv2.morphologyEx(combined, cv2.MORPH_OPEN, kernel)
            contours, _ = cv2.findContours(combined, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
            return contours
        except Exception as e:
            print(f"Error detecting outer contours: {str(e)}")
            return []

    def detect_inner_features(self, gray_image: np.ndarray) -> List[np.ndarray]:
        try:
            _, binary = cv2.threshold(gray_image, 180, 255, cv2.THRESH_BINARY)
            binary = cv2.bitwise_not(binary)
            edges = cv2.Canny(gray_image, 30, 100, apertureSize=3)
            combined = cv2.bitwise_or(binary, edges)
            kernel = np.ones((2, 2), np.uint8)
            combined = cv2.morphologyEx(combined, cv2.MORPH_CLOSE, kernel)
            contours, _ = cv2.findContours(combined, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
            inner_contours = []
            height, width = gray_image.shape
            min_area = (width * height) * 0.0005
            max_area = (width * height) * 0.15
            for contour in contours:
                area = cv2.contourArea(contour)
                if min_area <= area <= max_area:
                    perimeter = cv2.arcLength(contour, True)
                    if perimeter > 15:
                        x, y, w, h = cv2.boundingRect(contour)
                        aspect_ratio = float(w) / h
                        hull = cv2.convexHull(contour)
                        hull_area = cv2.contourArea(hull)
                        solidity = float(area) / hull_area if hull_area > 0 else 0
                        if 0.2 <= aspect_ratio <= 5.0 and solidity > 0.3:
                            inner_contours.append(contour)
            return inner_contours
        except Exception as e:
            print(f"Error detecting inner features: {str(e)}")
            return []

    def combine_and_filter_contours(self, outer_contours: List[np.ndarray],
                                    inner_contours: List[np.ndarray],
                                    settings: Dict[str, Any]) -> List[np.ndarray]:
        final_contours = []
        for contour in outer_contours:
            area = cv2.contourArea(contour)
            if settings['min_contour_area'] <= area <= settings['max_contour_area']:
                final_contours.append(contour)
        for contour in inner_contours:
            area = cv2.contourArea(contour)
            if area >= settings['min_contour_area'] * 0.5:
                final_contours.append(contour)
        return final_contours

    def smooth_contour(self, contour: np.ndarray, epsilon_factor: float = 0.008) -> np.ndarray:
        try:
            epsilon = epsilon_factor * cv2.arcLength(contour, True)
            smoothed = cv2.approxPolyDP(contour, epsilon, True)
            return smoothed
        except Exception as e:
            print(f"Error smoothing contour: {str(e)}")
            return contour

    def generate_dots_from_contours(self, contours: List[np.ndarray],
                                    difficulty: DifficultyLevel,
                                    image_shape: Tuple[int, int]) -> List[Dict[str, Any]]:
        settings = self.calculate_dynamic_settings(image_shape, difficulty)
        dot_spacing = settings['dot_spacing']
        dot_density = settings['dot_density']
        all_dots = []
        dot_number = 1
        used_positions = set()
        try:
            for contour_idx, contour in enumerate(contours):
                if len(contour) < 8:
                    continue
                smoothed = self.smooth_contour(contour)
                perimeter = cv2.arcLength(smoothed, True)
                if perimeter < dot_spacing * 1.5:
                    continue
                num_dots = max(3, int(perimeter / dot_spacing))
                if dot_density < 1.0:
                    num_dots = max(3, int(num_dots * dot_density))
                min_distance = int(dot_spacing * 0.5)
                contour_dots = self.distribute_dots_on_contour(smoothed, num_dots, dot_number, used_positions, min_distance)
                for dot in contour_dots:
                    dot['contour_id'] = contour_idx
                    dot['total_contours'] = len(contours)
                    dot['perimeter'] = perimeter
                all_dots.extend(contour_dots)
                dot_number += len(contour_dots)
            print(f"Generated {len(all_dots)} dots for {difficulty.value} level")
            return all_dots
        except Exception as e:
            print(f"Error generating dots: {str(e)}")
            return []

    def distribute_dots_on_contour(self, contour: np.ndarray, num_dots: int, start_number: int,
                                   used_positions: set, min_distance: int) -> List[Dict[str, Any]]:
        if len(contour.shape) == 3:
            points = contour.reshape(-1, 2)
        else:
            points = contour
        if len(points) < 2:
            return []
        distances = [0]
        for i in range(1, len(points)):
            dist = np.linalg.norm(points[i] - points[i - 1])
            distances.append(distances[-1] + dist)
        total_distance = distances[-1]
        if total_distance == 0:
            return []
        dots = []
        for i in range(num_dots):
            target_distance = (i / (num_dots - 1)) * total_distance if num_dots > 1 else 0
            for j in range(len(distances) - 1):
                if distances[j] <= target_distance <= distances[j + 1]:
                    segment_length = distances[j + 1] - distances[j]
                    ratio = (target_distance - distances[j]) / segment_length if segment_length > 0 else 0
                    x = int(points[j][0] + ratio * (points[j + 1][0] - points[j][0]))
                    y = int(points[j][1] + ratio * (points[j + 1][1] - points[j][1]))
                    is_too_close = False
                    for used_x, used_y in used_positions:
                        distance = np.sqrt((x - used_x) ** 2 + (y - used_y) ** 2)
                        if distance < min_distance:
                            is_too_close = True
                            break
                    if not is_too_close:
                        used_positions.add((x, y))
                        dots.append({
                            'number': start_number + i,
                            'x': x,
                            'y': y,
                            'position_ratio': i / (num_dots - 1) if num_dots > 1 else 0
                        })
                    break
        return dots

    def create_dot_image(self, original_image: np.ndarray, dots: List[Dict[str, Any]],
                         difficulty: DifficultyLevel, show_numbers: bool = True) -> np.ndarray:
        settings = self.calculate_dynamic_settings(original_image.shape, difficulty)
        result = np.ones_like(original_image, dtype=np.uint8) * 255  # White background
        transparency = settings['image_transparency']
        overlay = original_image.copy()
        result = cv2.addWeighted(result, 1 - transparency, overlay, transparency, 0)
        dot_size = settings['dot_size']
        font_scale = settings['number_font_scale']
        thickness = settings['number_thickness']
        dot_color = (0, 100, 200)
        text_color = (0, 0, 0)
        border_color = (255, 255, 255)
        for dot in dots:
            x, y = dot['x'], dot['y']
            cv2.circle(result, (x, y), dot_size + 1, border_color, -1)
            cv2.circle(result, (x, y), dot_size, dot_color, -1)
            if show_numbers:
                number = dot['number']
                font = cv2.FONT_HERSHEY_SIMPLEX
                text = str(number)
                (text_w, text_h), baseline = cv2.getTextSize(text, font, font_scale, thickness)
                offset = dot_size + max(8, int(settings['image_diagonal'] * 0.015))
                text_x = x + offset
                text_y = y + text_h // 2
                if text_x + text_w > result.shape[1]:
                    text_x = x - text_w - offset
                if text_y - text_h < 5:
                    text_y = y + offset + text_h
                elif text_y + baseline > result.shape[0] - 5:
                    text_y = y - offset
                padding = max(2, int(settings['image_diagonal'] * 0.003))
                cv2.rectangle(result,
                              (text_x - padding, text_y - text_h - padding),
                              (text_x + text_w + padding, text_y + baseline + padding),
                              border_color, -1)
                cv2.putText(result, text, (text_x, text_y), font, font_scale, text_color, thickness)
        return result

    def create_line_image(self, image_shape: Tuple[int, int], final_contours: List[np.ndarray]) -> np.ndarray:
        height, width = image_shape[:2]
        line_image = np.zeros((height, width, 4), dtype=np.uint8)  # RGBA, transparent background
        cv2.drawContours(line_image, final_contours, -1, (0, 0, 0, 255), 2)  # Black lines with alpha 255
        return line_image

    def create_image_folder(self, image_name: str) -> Tuple[str, str, str]:
        base_name = os.path.splitext(image_name)[0]
        draw_folder = os.path.join(self.output_folder, base_name, "draw")
        learn_folder = os.path.join(self.output_folder, base_name, "learn")
        lines_folder = os.path.join(self.output_folder, base_name, "lines")
        os.makedirs(draw_folder, exist_ok=True)
        os.makedirs(learn_folder, exist_ok=True)
        os.makedirs(lines_folder, exist_ok=True)
        return draw_folder, learn_folder, lines_folder

    def save_dot_data(self, dots: List[Dict[str, Any]], image_name: str,
                      difficulty: DifficultyLevel, folder: str, is_learn: bool = False) -> None:
        try:
            base_name = os.path.splitext(image_name)[0]
            data = {
                'image_name': image_name,
                'difficulty': difficulty.value,
                'total_dots': len(dots),
                'settings_used': self.base_settings[difficulty]
            }
            if is_learn:
                # Group dots by contour_id for learn feature
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
                data['contours'] = [
                    {
                        'contour_id': contour_id,
                        'dots': dots,
                        'close_contour': True  # Indicate that the contour should be closed
                    }
                    for contour_id, dots in contours_dots.items()
                ]
            else:
                # Flat dots list for draw feature
                data['dots'] = dots
            path = os.path.join(folder, f"{base_name}_{'learn' if is_learn else 'draw'}_{difficulty.value}_dots.json")
            with open(path, 'w') as f:
                json.dump(data, f, indent=2)
            print(f"Saved dot data: {path}")
        except Exception as e:
            print(f"Error saving dot data: {str(e)}")

    def create_debug_images(self, original: np.ndarray, outer: List[np.ndarray],
                           inner: List[np.ndarray], final: List[np.ndarray],
                           folder: str, name: str) -> None:
        base = os.path.splitext(name)[0]
        debug1 = original.copy()
        debug2 = original.copy()
        debug3 = original.copy()
        cv2.drawContours(debug1, outer, -1, (0, 255, 0), 2)
        cv2.drawContours(debug2, inner, -1, (0, 0, 255), 2)
        cv2.drawContours(debug3, final, -1, (255, 0, 0), 2)
        cv2.imwrite(os.path.join(folder, f"{base}_debug_outer.png"), debug1)
        cv2.imwrite(os.path.join(folder, f"{base}_debug_inner.png"), debug2)
        cv2.imwrite(os.path.join(folder, f"{base}_debug_final.png"), debug3)

    def process_draw_image(self, image_filename: str, original: np.ndarray, gray: np.ndarray,
                           draw_folder: str, lines_folder: str) -> None:
        outer = self.detect_outer_contours(gray)
        inner = self.detect_inner_features(gray)
        settings = self.calculate_dynamic_settings(original.shape, DifficultyLevel.MEDIUM)
        final = self.combine_and_filter_contours(outer, inner, settings)
        if not final:
            print("No valid contours found for draw feature.")
            return
        self.create_debug_images(original, outer, inner, final, draw_folder, image_filename)
        base = os.path.splitext(image_filename)[0]
        # Save line image for coloring
        line_image = self.create_line_image(original.shape, final)
        cv2.imwrite(os.path.join(lines_folder, f"{base}_lines.png"), line_image)
        for difficulty in DifficultyLevel:
            dots = self.generate_dots_from_contours(final, difficulty, original.shape)
            if not dots:
                continue
            img = self.create_dot_image(original, dots, difficulty, show_numbers=False)
            path = os.path.join(draw_folder, f"draw_{base}_{difficulty.value}.png")
            cv2.imwrite(path, img)
            self.save_dot_data(dots, image_filename, difficulty, draw_folder, is_learn=False)

    def process_learn_image(self, image_filename: str, original: np.ndarray, gray: np.ndarray,
                            learn_folder: str) -> None:
        outer = self.detect_outer_contours(gray)
        if not outer:
            print("No valid contours found for learn feature.")
            return
        settings = self.calculate_dynamic_settings(original.shape, DifficultyLevel.MEDIUM)
        filtered_contours = [contour for contour in outer if settings['min_contour_area'] <= cv2.contourArea(contour) <= settings['max_contour_area']]
        if not filtered_contours:
            print("No valid contours after filtering for learn feature.")
            return
        base = os.path.splitext(image_filename)[0]
        for difficulty in DifficultyLevel:
            dots = self.generate_dots_from_contours(filtered_contours, difficulty, original.shape)
            if not dots:
                continue
            img = self.create_dot_image(original, dots, difficulty, show_numbers=True)
            path = os.path.join(learn_folder, f"learn_{base}_{difficulty.value}.png")
            cv2.imwrite(path, img)
            self.save_dot_data(dots, image_filename, difficulty, learn_folder, is_learn=True)

    def process_single_image(self, image_filename: str) -> None:
        input_path = os.path.join(self.input_folder, image_filename)
        draw_folder, learn_folder, lines_folder = self.create_image_folder(image_filename)
        original, gray = self.load_and_preprocess_image(input_path)
        if original is None:
            return
        self.process_draw_image(image_filename, original, gray, draw_folder, lines_folder)
        self.process_learn_image(image_filename, original, gray, learn_folder)

    def process_all_images(self) -> None:
        print("=== Dot-to-Dot Generator ===")
        exts = ('.png', '.jpg', '.jpeg')
        images = [f for f in os.listdir(self.input_folder) if f.lower().endswith(exts)]
        if not images:
            print("No images found. Please add drawings to input_images.")
            return
        for image_file in images:
            self.process_single_image(image_file)
        print("=== Processing Complete ===")

def main():
    generator = DotToDotGenerator()
    start_time = time.time()
    if not os.path.exists(generator.input_folder):
        os.makedirs(generator.input_folder)
        print("Please add drawings to input_images.")
        return
    generator.process_all_images()
    end_time = time.time()
    execution_time = end_time - start_time
    print(f"procissing time {execution_time:.4f} second")

if __name__ == "__main__":
    main()
