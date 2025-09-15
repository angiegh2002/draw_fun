# 🎨 Draw Fun

> **An AI-powered interactive system that transforms images into numbered guide points to teach children how to draw step by step**

![Python](https://img.shields.io/badge/Python-3.13.5-blue ) 
![Flutter](https://img.shields.io/badge/Flutter-%2302569B?logo=flutter&logoColor=white)  
![OpenCV]( https://img.shields.io/badge/OpenCV-%2327338e?logo=opencv&logoColor=white)  
![Streamlit]( https://img.shields.io/badge/Streamlit-FAC84B?logo=streamlit&logoColor=black)

This project introduces an intelligent and interactive drawing learning system designed for children aged 3–12. By leveraging computer vision and image processing techniques, the system converts input images into structured, numbered guide points, enabling children to learn drawing through a fun, guided, and educational experience.

## 🌟 Overview

The system breaks down complex drawings into simple, sequential steps using **numbered tracing points**, helping children develop fine motor skills, hand-eye coordination, and artistic confidence. It emphasizes simplicity, safety, and interactivity—ensuring a child-friendly environment with no collection of personal data.

## ✨ Key Features

- ✅ **Automatic Image-to-Points Conversion**: Uses advanced image processing to extract contours and generate guide points.
- 🖼️ **Three Interactive Learning Modes**:
  - **Learning Mode**: Connect the dots in order.
  - **Free Drawing Mode**: Draw freely using guide points as reference.
  - **Coloring Mode**: Color pre-outlined images with transparent backgrounds.
- 🔤 **Multiple Difficulty Levels**: Easy, Medium, and Hard—adapted to different age groups and skill levels.
- 👨‍🏫 **Admin Dashboard**: A management panel for supervisors to add, edit, or remove images and categories easily.
- ⚙️ **Smart Image Processing Pipeline** using:
  - `Canny Edge Detection`
  - `Contour Extraction` (via OpenCV)
  - `Ramer-Douglas-Peucker` algorithm for contour simplification
  - Linear interpolation for balanced point distribution

## 🛠️ Technologies Used

| Layer | Technology |
|------|------------|
| **User App (Frontend)** | Flutter (Android/iOS) |
| **Admin Panel** | Streamlit (Web Dashboard) |
| **Backend Processing** | Python + OpenCV |
| **Image Processing** | Grayscale conversion, edge detection, contour analysis |

## 🚀 How to Run

### 1. Launch the Admin Panel (Streamlit)
```bash
cd admin-panel
streamlit run admin_front.py
```

### 2. Run the (Backend)
```bash
python manage.py runserver
```

### 3. Run the Mobile App (Flutter)
```bash
cd app
flutter run
```

 
