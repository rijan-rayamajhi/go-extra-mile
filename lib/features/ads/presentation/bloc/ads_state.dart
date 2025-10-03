import 'package:equatable/equatable.dart';
import '../../domain/entities/carousel_ad.dart';

/// Abstract base class for all ads states
abstract class AdsState extends Equatable {
  const AdsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the ads feature loads
class AdsInitial extends AdsState {
  const AdsInitial();
}

/// Loading state during data operations
class AdsLoading extends AdsState {
  const AdsLoading();
}

/// State when no ads are available
class AdsEmpty extends AdsState {
  const AdsEmpty();
}

/// State when carousel ads are successfully loaded
class AdsLoaded extends AdsState {
  final List<CarouselAd> ads;

  const AdsLoaded({required this.ads});

  @override
  List<Object?> get props => [ads];
}

/// Error state when operations fail
class AdsError extends AdsState {
  final String message;

  const AdsError({required this.message});

  @override
  List<Object?> get props => [message];
}
