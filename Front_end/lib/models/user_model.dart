class UserModel {
  final String id;
  final String username;
  final int age;
  final String? parentEmail;
  final double? stars;

  UserModel({
    required this.id,
    required this.username,
    required this.age,
    this.parentEmail,
    this.stars,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      // Convert id to String in case it's numeric
      username: json['username'] as String,
      age: (json['age'] as num).toInt(),
      parentEmail: json['parent_email'] as String?,
      stars: (json['stars'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'age': age,
      'parent_email': parentEmail,
      'stars': stars,
    };
  }
}
