class OptionModel {
  final String id;
  final String optionText;
  final int optionOrder;
  final bool isCorrect;

  const OptionModel({
    required this.id,
    required this.optionText,
    required this.optionOrder,
    required this.isCorrect,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] as String,
      optionText: json['optionText'] as String,
      optionOrder: json['optionOrder'] as int,
      isCorrect: json['isCorrect'] as bool,
    );
  }
}
