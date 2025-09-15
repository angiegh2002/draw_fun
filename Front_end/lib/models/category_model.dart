class CategoryModel {
  final int id;
  final String name;
  final String image;
  final int drawingCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.drawingCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      drawingCount: json['drawing_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'drawing_count': drawingCount,
    };
  }
}
