import 'dart:io' show Platform;

import 'package:device_info/device_info.dart';
import 'package:ios_utsname_ext/extension.dart';
import 'package:package_info/package_info.dart';

Future<Map<String, dynamic>> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceData = <String, dynamic>{};

  try {
    if (Platform.isAndroid) {
      deviceData = _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  } catch (error) {
    deviceData = {"Error": "Failed to get platform version."};
  }

  return deviceData;
}

Future<Map<String, dynamic>> getAppInfo() async {
  PackageInfo info = await PackageInfo.fromPlatform();

  return {
    "앱 이름": info.appName,
    "앱 버전": info.version,
    "빌드 번호": info.buildNumber,
  };
}

Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo info) {
  var release = info.version.release;
  var sdkInt = info.version.sdkInt;
  var manufacturer = info.manufacturer;
  var model = info.model;

  return {
    "OS 버전": "Android $release (SDK $sdkInt)",
    "기기": "$manufacturer $model"
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) {
  var systemName = info.systemName;
  var version = info.systemVersion;
  var machine = info.utsname.machine.iOSProductName;

  return {"OS 버전": "$systemName $version", "기기": "$machine"};
}
