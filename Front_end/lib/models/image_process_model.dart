//
// class ProcessedImageModel {
//   final int drawingId;
//   final String title;
//   final int category;
//   final String inputImage;
//   final String lineImage;
//   final List<LevelModel> levels;
//   final int currentDot;
//
//   ProcessedImageModel({
//     required this.drawingId,
//     required this.title,
//     required this.category,
//     required this.inputImage,
//     required this.lineImage,
//     required this.levels,
//     required this.currentDot,
//   });
//
//   factory ProcessedImageModel.fromJson(Map<String, dynamic> json) {
//     final data = json['data'] as Map<String, dynamic>;
//     return ProcessedImageModel(
//       drawingId: json['drawing_id'] as int,
//       title: data['title'] as String,
//       category: data['category'] as int,
//       inputImage: data['input_image'] as String,
//       lineImage: data['line_image'] as String,
//       levels: (data['levels'] as List<dynamic>)
//           .map((level) => LevelModel.fromJson(level as Map<String, dynamic>))
//           .toList(),
//       currentDot: data['current_dot'] as int,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'drawing_id': drawingId,
//       'data': {
//         'title': title,
//         'category': category,
//         'input_image': inputImage,
//         'line_image': lineImage,
//         'levels': levels.map((level) => level.toJson()).toList(),
//         'current_dot': currentDot,
//       },
//     };
//   }
// }
