import 'option_model.dart';

class QuestionModel {
  final String id;
  final String content;
  final String topic;
  final String difficulty;
  final String? explanation;
  final String? mnemonic;
  final String? scenario;
  final List<String> tags;
  final List<OptionModel> options;

  const QuestionModel({
    required this.id,
    required this.content,
    required this.topic,
    required this.difficulty,
    required this.explanation,
    required this.mnemonic,
    required this.scenario,
    required this.tags,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>;
    return QuestionModel(
      id: json['id'] as String,
      content: json['content'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      explanation: json['explanation'] as String?,
      mnemonic: json['mnemonic'] as String?,
      scenario: json['scenario'] as String?,
      tags: List<String>.from(json['tags'] as List<dynamic>),
      options: optionsJson
          .map((option) => OptionModel.fromJson(option as Map<String, dynamic>))
          .toList(),
    );
  }

  int get correctAnswerIndex {
    final index = options.indexWhere((option) => option.isCorrect);
    return index >= 0 ? index : -1;
  }
}
