import 'package:equatable/equatable.dart';

class Faq extends Equatable {
  final String id;
  final String question;
  final String answer;

  const Faq({
    required this.id,
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [id, question, answer];
}
