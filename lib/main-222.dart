import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionExample extends StatefulWidget {
  @override
  State<CameraPermissionExample> createState() =>
      _CameraPermissionExampleState();
}

class _CameraPermissionExampleState extends State<CameraPermissionExample> {
  Future<void> requestCameraPermission() async {
    // 检查权限状态
    var status = await Permission.camera.status;

    if (status.isDenied) {
      // 请求权限
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      // 提示用户打开系统设置
      openAppSettings();
    }

    if (status.isGranted) {
      // 权限已授予
      print('Camera permission granted!');
    } else {
      // 权限被拒绝
      print('Camera permission denied!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Permission')),
      body: Center(
        child: ElevatedButton(
          onPressed: requestCameraPermission,
          child: const Text('Request Camera Permission'),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: CameraPermissionExample()));
