import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Service to fetch device information like model, OS version, and more.
/// Wraps the device_info_plus package for easy access across the app.
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Fetches a user-friendly device info summary string.
  Future<String> getDeviceInfoSummary() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), '
            '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return 'iOS ${iosInfo.systemVersion}, ${iosInfo.name} ${iosInfo.model}';
      } else {
        return 'Unsupported platform';
      }
    } catch (e) {
      return 'Failed to get device info: $e';
    }
  }

  /// Gets detailed Android device info as a map.
  Future<Map<String, dynamic>?> getAndroidDeviceInfo() async {
    if (!Platform.isAndroid) return null;
    try {
      final info = await _deviceInfoPlugin.androidInfo;
      return _readAndroidBuildData(info);
    } catch (e) {
      return null;
    }
  }

  /// Gets detailed iOS device info as a map.
  Future<Map<String, dynamic>?> getIosDeviceInfo() async {
    if (!Platform.isIOS) return null;
    try {
      final info = await _deviceInfoPlugin.iosInfo;
      return _readIosDeviceInfo(info);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.id,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}


