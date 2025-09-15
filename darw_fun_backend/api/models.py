# from django.db import models
# import json

# class User(models.Model):
#     id = models.AutoField(primary_key=True)
#     username = models.CharField(max_length=100, unique=True)
#     age = models.IntegerField()
#     parent_email = models.EmailField(blank=True, null=True)
#     stars = models.FloatField(default=0.0)

#     def __str__(self):
#         return self.username

# class Category(models.Model):
#     name = models.CharField(max_length=50, unique=True)
#     image = models.ImageField(upload_to='categories/', blank=True, null=True)  

#     def __str__(self):
#         return self.name
    
# class Drawing(models.Model):
#     id = models.AutoField(primary_key=True)
#     title = models.CharField(max_length=100)
#     category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='drawings')  
#     input_image = models.ImageField(upload_to='drawings/input/', blank=True, null=True)  # Retained
#     easy_preview = models.ImageField(upload_to='drawings/', blank=True, null=True)
#     easy_coordinates = models.JSONField(default=list)
#     medium_preview = models.ImageField(upload_to='drawings/', blank=True, null=True)
#     medium_coordinates = models.JSONField(default=list)
#     hard_preview = models.ImageField(upload_to='drawings/', blank=True, null=True)
#     hard_coordinates = models.JSONField(default=list)
#     current_dot = models.IntegerField(default=0)

#     def __str__(self):
#         return self.title

# class Achievement(models.Model):
#     id = models.AutoField(primary_key=True)
#     name = models.CharField(max_length=100)
#     icon_path = models.CharField(max_length=200)
#     earned_by = models.ManyToManyField(User, related_name='achievements', blank=True)

#     def __str__(self):
#         return self.name
from django.db import models
import json

class User(models.Model):
    id = models.AutoField(primary_key=True)
    username = models.CharField(max_length=100, unique=True)
    age = models.IntegerField()
    parent_email = models.EmailField(blank=True, null=True)
    stars = models.FloatField(default=0.0)

    def __str__(self):
        return self.username

class Category(models.Model):
    name = models.CharField(max_length=50, unique=True)
    image = models.ImageField(upload_to='categories/', blank=True, null=True)  

    def __str__(self):
        return self.name

class Drawing(models.Model):
    id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=100)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='drawings')  
    input_image = models.ImageField(blank=True, null=True)
    current_dot = models.IntegerField(default=0)  
    outline_image = models.ImageField(blank=True, null=True)  
    progress = models.JSONField(default=dict, blank=True)  
    is_completed = models.JSONField(default=dict, blank=True)  

    easy_draw_preview = models.ImageField( blank=True, null=True)
    medium_draw_preview = models.ImageField( blank=True, null=True)
    hard_draw_preview = models.ImageField( blank=True, null=True)
    easy_coordinates = models.JSONField(default=list)  
    medium_coordinates = models.JSONField(default=list)
    hard_coordinates = models.JSONField(default=list)

    easy_learn_preview = models.ImageField( blank=True, null=True)
    medium_learn_preview = models.ImageField(blank=True, null=True)
    hard_learn_preview = models.ImageField(blank=True, null=True)
    easy_learn_coordinates = models.JSONField(default=list) 
    medium_learn_coordinates = models.JSONField(default=list)
    hard_learn_coordinates = models.JSONField(default=list)

    def __str__(self):
        return self.title

class Achievement(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    icon_path = models.CharField(max_length=200)
    earned_by = models.ManyToManyField(User, related_name='achievements', blank=True)

    def __str__(self):
        return self.name