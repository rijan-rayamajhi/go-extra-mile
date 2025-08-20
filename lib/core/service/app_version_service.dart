import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  final FirebaseFirestore _firestore;

  AppVersionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> getLocalVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // e.g., "1.0.3"
  }

  Future<String> getLocalBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber; // e.g., "12"
  }

  /// Fetch the latest version string from Firestore
  Future<String?> getRemoteLatestVersion() async {
    try {
      final doc = await _firestore.collection('app_config').doc('version_info').get();
      if (doc.exists) {
        return doc.get('latest_version') as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Compare two semantic versions: returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal
  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    final maxLength = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;

    for (int i = 0; i < maxLength; i++) {
      final part1 = i < v1Parts.length ? v1Parts[i] : 0;
      final part2 = i < v2Parts.length ? v2Parts[i] : 0;
      if (part1 > part2) return 1;
      if (part1 < part2) return -1;
    }
    return 0;
  }

  /// Returns true if an update is available (remote version > local version)
  Future<bool> isUpdateAvailable() async {
    final localVersion = await getLocalVersion();
    final remoteVersion = await getRemoteLatestVersion();

    if (remoteVersion == null) {
      // Could not fetch remote version, assume no update available
      return false;
    }

    return _compareVersions(remoteVersion, localVersion) > 0;
  }
}
