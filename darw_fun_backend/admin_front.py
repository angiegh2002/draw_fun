import streamlit as st
import requests
import io
import time
from PIL import Image

API_BASE = "http://localhost:8000/api"


class ApiClient:
    def __init__(self, base_url):
        self.base_url = base_url

    def get(self, endpoint, params=None):
        try:
            return requests.get(f"{self.base_url}{endpoint}", params=params)
        except:
            return None

    def post(self, endpoint, data=None, files=None):
        try:
            return requests.post(f"{self.base_url}{endpoint}", data=data, files=files)
        except:
            return None

    def delete(self, endpoint):
        try:
            return requests.delete(f"{self.base_url}{endpoint}")
        except:
            return None


class UIHelper:
    @staticmethod
    def show_success(message):
        st.markdown(f"<div class='success-alert'>{message}</div>", unsafe_allow_html=True)

    @staticmethod
    def show_error(message):
        st.markdown(f"<div class='error-alert'>{message}</div>", unsafe_allow_html=True)

    @staticmethod
    def show_warning(message):
        st.markdown(f"<div class='warning-alert'>{message}</div>", unsafe_allow_html=True)

class UserManager:
    def __init__(self, api: ApiClient):
        self.api = api

    def render(self):
        st.markdown("<h2 style='text-align: center;'> User Management</h2>", unsafe_allow_html=True)
        tab1, tab2 = st.tabs(["View Users", "Delete User"])

        with tab1:
            st.markdown("<div class='card'><h3> Users List</h3>", unsafe_allow_html=True)
            response = self.api.get("/user/lookup/")
            if response and response.status_code == 200:
                users = response.json()
                if isinstance(users, dict) and "error" in users:
                    UIHelper.show_warning("No users available at the moment.")
                else:
                    st.markdown(f"<p style='font-size: 18px;'><strong>Total Users:</strong> {len(users)}</p>", unsafe_allow_html=True)
                    for i, user in enumerate(users, 1):
                        st.markdown(f"""
                        <div style='background:#f8f9fa; padding:15px; margin:10px 0; border-radius:10px; border-left:4px solid #4CAF50;'>
                            <h4>User #{i}</h4>
                            <p><b>Username:</b> {user['username']}</p>
                            <p><b>Age:</b> {user['age']} years</p>
                        </div>
                        """, unsafe_allow_html=True)
            else:
                UIHelper.show_error("Failed to load users.")
            st.markdown("</div>", unsafe_allow_html=True)

        with tab2:
            st.markdown("<div class='card'><h3> Delete User</h3>", unsafe_allow_html=True)
            col1, col2 = st.columns(2)
            with col1:
                username = st.text_input("User name")
            with col2:
                age = st.number_input(" Age", min_value=1, max_value=100, step=1)

            if st.button("Search for User", use_container_width=True):
                if username and age:
                    lookup_response = self.api.get("/user/lookup/", params={"username": username, "age": age})
                    if lookup_response and lookup_response.status_code == 200:
                        user_data = lookup_response.json()
                        if "error" not in user_data:
                            st.session_state.user_to_delete = user_data
                            UIHelper.show_success(f"User found: {user_data['username']}")
                        else:
                            UIHelper.show_error("User not found.")
                    else:
                        UIHelper.show_error("Server connection error.")
                else:
                    UIHelper.show_warning("Please enter username and age.")

            if "user_to_delete" in st.session_state:
                user = st.session_state.user_to_delete
                st.markdown(f"""
                <div style='background:#fff3cd; padding:15px; border-radius:10px; border-left:5px solid #ffc107;'>
                    <h4>Delete Confirmation</h4>
                    <p><b>Name:</b> {user['username']}<br><b>Age:</b> {user['age']} years</p>
                </div>
                """, unsafe_allow_html=True)

                col1, col2 = st.columns(2)
                with col1:
                    if st.button("Yes, Delete", use_container_width=True):
                        delete_response = self.api.delete(f"/user/{user['id']}/delete/")
                        if delete_response and delete_response.status_code == 204:
                            UIHelper.show_success("User deleted successfully!")
                            del st.session_state.user_to_delete
                            st.rerun()
                        else:
                            UIHelper.show_error("Delete failed.")

                with col2:
                    if st.button("Cancel", use_container_width=True):
                        del st.session_state.user_to_delete
                        st.rerun()
            st.markdown("</div>", unsafe_allow_html=True)


class CategoryManager:
    def __init__(self, api: ApiClient):
        self.api = api

    def render(self):
        st.markdown("<h2 style='text-align: center;'> Category Management</h2>", unsafe_allow_html=True)
        tab1, tab2, tab3 = st.tabs(["View Categories", "Add Category", "Delete Category"])

        with tab1:
            st.markdown("<div class='card'><h3> Current Categories</h3>", unsafe_allow_html=True)
            response = self.api.get("/categories/")
            if response and response.status_code == 200:
                categories = response.json()
                if categories:
                    st.markdown(f"<p><b>Total Categories:</b> {len(categories)}</p>", unsafe_allow_html=True)
                    cols = st.columns(3)
                    for i, cat in enumerate(categories):
                        with cols[i % 3]:
                            st.markdown(f"""
                            <div style='background:#e3f2fd; padding:15px; margin:10px 0; border-radius:10px; border-left:4px solid #2196F3;'>
                                <h4>{cat['name']}</h4>
                                <p><b>Drawings:</b> {cat['drawing_count']}</p>
                            </div>
                            """, unsafe_allow_html=True)
                else:
                    UIHelper.show_warning("No categories available.")
            else:
                UIHelper.show_error("Failed to load categories.")
            st.markdown("</div>", unsafe_allow_html=True)

        with tab2:
            st.markdown("<div class='card'><h3> Add New Category</h3>", unsafe_allow_html=True)
            new_name = st.text_input("Category Name")
            new_image = st.file_uploader("Category Image", type=["png","jpg","jpeg"])
            if st.button("Add Category", use_container_width=True):
                if not new_name.strip():
                    UIHelper.show_error("Category name required.")
                elif new_image is None:
                    UIHelper.show_error("Category image required.")
                else:
                    data = {"name": new_name.strip()}
                    files = {"image": (new_image.name, new_image.getvalue(), new_image.type)}
                    res = self.api.post("/categories/", data=data, files=files)
                    if res and res.status_code == 201:
                        UIHelper.show_success("Category added successfully!")
                        st.rerun()
                    else:
                        UIHelper.show_error("Failed to add category.")
            st.markdown("</div>", unsafe_allow_html=True)

        with tab3:
            st.markdown("<div class='card'><h3> Delete Category</h3>", unsafe_allow_html=True)
            response = self.api.get("/categories/")
            if response and response.status_code == 200:
                categories = response.json()
                if categories:
                    cat_map = {c['name']: c['id'] for c in categories}
                    selected = st.selectbox("Select category", list(cat_map.keys()))
                    if st.button("Delete Category", use_container_width=True):
                        del_res = self.api.delete(f"/categories/{cat_map[selected]}/delete/")
                        if del_res and del_res.status_code == 204:
                            UIHelper.show_success("Category deleted successfully!")
                            st.rerun()
                        else:
                            UIHelper.show_error("Failed to delete category.")
                else:
                    UIHelper.show_warning("No categories to delete.")
            else:
                UIHelper.show_error("Failed to load categories.")
            st.markdown("</div>", unsafe_allow_html=True)


class DrawingManager:
    def __init__(self, api: ApiClient):
        self.api = api

    def render(self):
        st.markdown("<h2 style='text-align: center;'> Drawing Management</h2>", unsafe_allow_html=True)
        tab1, tab2, tab3 = st.tabs(["View Drawings", "Add Drawing", "Delete Drawing"])

        with tab1:
            st.markdown("<div class='card'><h3> Current Drawings</h3>", unsafe_allow_html=True)
            res = self.api.get("/drawings/")
            if res and res.status_code == 200:
                drawings = res.json()
                if drawings:
                    st.markdown(f"<p><b>Total Drawings:</b> {len(drawings)}</p>", unsafe_allow_html=True)
                    cols = st.columns(3)
                    for i, dr in enumerate(drawings):
                        with cols[i % 3]:
                            st.markdown(f"""
                            <div style='background:#f5f5f5; padding:10px; margin:10px 0; border-radius:10px; border:1px solid #ddd;'>
                                <h4>{dr['title']}</h4>
                                <p><b>Category:</b> {dr['category']}</p>
                            </div>
                            """, unsafe_allow_html=True)
                            if dr.get("input_image"):
                                st.image(f"http://localhost:8000{dr['input_image']}", width=150, caption=dr['title'])
                else:
                    UIHelper.show_warning("No drawings available.")
            else:
                UIHelper.show_error("Failed to load drawings.")
            st.markdown("</div>", unsafe_allow_html=True)

        with tab2:
            st.markdown("<div class='card'><h3> Add New Drawing</h3>", unsafe_allow_html=True)
            uploaded = st.file_uploader("Upload image", type=["png","jpg","jpeg"])
            if uploaded:
                try:
                    image = Image.open(uploaded)
                    if image.mode != "RGB":
                        image = image.convert("RGB")
                    resized = image.resize((250,250))
                    img_bytes = io.BytesIO()
                    resized.save(img_bytes, format="PNG")
                    img_bytes.seek(0)
                    st.session_state['processed_image'] = img_bytes
                    st.session_state['filename'] = uploaded.name
                    st.image(resized, caption=f"Resized {uploaded.name}", width=250)
                except Exception as e:
                    UIHelper.show_error(str(e))

            cats = self.api.get("/categories/")
            if cats and cats.status_code == 200:
                categories = cats.json()
                if categories:
                    cat_map = {c['name']: c['id'] for c in categories}
                    selected = st.selectbox("Select Category", list(cat_map.keys()))
                    if st.button("Process Image & Create Drawing", use_container_width=True):
                        if 'processed_image' not in st.session_state:
                            UIHelper.show_warning("Upload image first.")
                        else:
                            files = {"image": (st.session_state['filename'], st.session_state['processed_image'], "image/png")}
                            data = {"category_id": cat_map[selected]}
                            start = time.time()
                            res = self.api.post("/process-image/", data=data, files=files)
                            duration = time.time()-start
                            if res and res.status_code == 201:
                                UIHelper.show_success(f"Drawing created successfully! ({duration:.2f}s)")
                                st.balloons()
                                del st.session_state['processed_image']
                                del st.session_state['filename']
                            else:
                                UIHelper.show_error("Failed to create drawing.")
                else:
                    UIHelper.show_warning("Create a category first.")
            st.markdown("</div>", unsafe_allow_html=True)

        with tab3:
            st.markdown("<div class='card'><h3> Delete Drawing</h3>", unsafe_allow_html=True)
            res = self.api.get("/drawings/")
            if res and res.status_code == 200:
                drawings = res.json()
                if drawings:
                    dr_map = {d['title']: d['id'] for d in drawings}
                    selected = st.selectbox("Select Drawing", list(dr_map.keys()))
                    if st.button("Delete Drawing", use_container_width=True):
                        del_res = self.api.delete(f"/drawings/{dr_map[selected]}/delete/")
                        if del_res and del_res.status_code == 204:
                            UIHelper.show_success("Drawing deleted successfully!")
                            st.rerun()
                        else:
                            UIHelper.show_error("Failed to delete drawing.")
                else:
                    UIHelper.show_warning("No drawings to delete.")
            else:
                UIHelper.show_error("Failed to load drawings.")
            st.markdown("</div>", unsafe_allow_html=True)


class DashboardApp:
    def __init__(self):
        self.api = ApiClient(API_BASE)
        self.user_manager = UserManager(self.api)
        self.category_manager = CategoryManager(self.api)
        self.drawing_manager = DrawingManager(self.api)

    def run(self):
        st.set_page_config(page_title="Dot-to-Dot Admin", layout="wide", page_icon="🎨")

        # CSS Styles
        st.markdown("""<style> ... (نفس CSS الأصلي يوضع هنا) ... </style>""", unsafe_allow_html=True)

        st.markdown("<h1 style='text-align: center; color: #9c27b0;'>DrawFun_Dashboard</h1>", unsafe_allow_html=True)
        st.markdown("<hr style='border:2px solid #9c27b0; border-radius:5px;'>", unsafe_allow_html=True)

        with st.sidebar:
            st.markdown("<h2 style='color:#7e57c2;'>Main Menu</h2>", unsafe_allow_html=True)
            menu = st.selectbox("Choose Section", ["Users","Categories","Drawings"])

        if menu == "Users":
            self.user_manager.render()
        elif menu == "Categories":
            self.category_manager.render()
        elif menu == "Drawings":
            self.drawing_manager.render()

        st.markdown("<hr style='border:1px solid #ddd; margin-top:50px;'>", unsafe_allow_html=True)
        st.markdown("<p style='text-align:center; color:#666;'>© 2025 DrawFun Dashboard</p>", unsafe_allow_html=True)

if __name__ == "__main__":
    app = DashboardApp()
    app.run()