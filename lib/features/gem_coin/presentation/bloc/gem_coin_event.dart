import 'package:equatable/equatable.dart';

abstract class GemCoinEvent extends Equatable {
  const GemCoinEvent();

  @override
  List<Object?> get props => [];
}

class LoadGemCoinHistory extends GemCoinEvent {
  final String uid;
  const LoadGemCoinHistory(this.uid);

  @override
  List<Object?> get props => [uid];
}