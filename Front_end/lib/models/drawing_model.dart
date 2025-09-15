class DrawingModel {
  final int id;
  final String title;
  final int category;
  final String imageUrl;

  DrawingModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
  });

  factory DrawingModel.fromJson(Map<String, dynamic> json) {
    return DrawingModel(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as int,
      imageUrl: json['input_image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'input_image': imageUrl,
    };
  }
}
