import 'package:go_extra_mile_new/features/home/domain/home_repositories.dart';

class GetUnreadNotification {
  final HomeRepository repository;

  GetUnreadNotification(this.repository);

  Future<String> call() async {
    return await repository.getUnreadNotification();
  }
}
