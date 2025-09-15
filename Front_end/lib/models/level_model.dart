class Dot {
  final int x;
  final int y;
  final int number;
  final double positionRatio;

  Dot({
    required this.x,
    required this.y,
    required this.number,
    required this.positionRatio,
  });

  factory Dot.fromJson(Map<String, dynamic> json) {
    return Dot(
      x: json['x'] as int,
      y: json['y'] as int,
      number: json['number'] as int? ?? 0,
      positionRatio: (json['position_ratio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'number': number,
      'position_ratio': positionRatio,
    };
  }
}

class LevelModel {
  final String imageUrl;
  final int totalDots;
  final int currentIndex;
  final String mode;
  final Dot currentDot;
  final Dot? nextDot;
  final int contourId;
  final bool closeContour;
  final bool isCompleted;
  final String? message;

  LevelModel({
    required this.imageUrl,
    required this.totalDots,
    required this.currentIndex,
    required this.mode,
    required this.currentDot,
    this.nextDot,
    required this.contourId,
    required this.closeContour,
    required this.isCompleted,
    this.message,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      imageUrl: json['image_url'] as String? ?? "",
      totalDots: json['total_dots'] as int? ?? 0,
      currentIndex: json['current_index'] as int? ?? 0,
      mode: json['mode'] as String? ?? "learn",
      currentDot: Dot.fromJson(json['current_dot'] as Map<String, dynamic>),
      nextDot: json['next_dot'] != null
          ? Dot.fromJson(json['next_dot'] as Map<String, dynamic>)
          : null,
      contourId: json['contour_id'] as int? ?? 0,
      closeContour: json['close_contour'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'total_dots': totalDots,
      'current_index': currentIndex,
      'mode': mode,
      'current_dot': currentDot.toJson(),
      'next_dot': nextDot?.toJson(),
      'contour_id': contourId,
      'close_contour': closeContour,
      'is_completed': isCompleted,
      'message': message,
    };
  }
}
