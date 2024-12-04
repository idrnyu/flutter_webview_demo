import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(home: WebViewApp()));
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController _controller;
  final ImagePicker _imagePicker = ImagePicker();

  /// 打开相册返回图片URI
  Future<List<String>> _openGallery(bool isCaptureEnabled) async {
    // source: ImageSource.gallery // 打开用户相册
    // source: ImageSource.camera // 打开摄像头
    final XFile? image = await _imagePicker.pickImage(source: isCaptureEnabled ? ImageSource.camera : ImageSource.gallery);
    if (image != null) {
      final String filePath = image.path;
      final Uri fileUri = Uri.file(filePath);
      return [fileUri.toString()];
    }
    print("没有选择图片");
    return [];
  }
  /// 打开文件管理器返回文件的URI
  Future<List<String>> _openFile(List<String>? acceptTypes) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // 是否允许多选
      // type: FileType.image, // image
      type: FileType.custom, // 自定义类型
      allowedExtensions: acceptTypes, // 子允许自定义类型文件
      // allowedExtensions: ['pdf', 'doc'], // 只允许pdf doc类型
    );
    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path!; // 获取的是单个文件
      print("console.log: $filePath");
      Uri fileUri = Uri.file(filePath);
      return [fileUri.toString()];
    }
    print("没有选择文件");
    return [];
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse('http://192.168.12.137:10086/'));

    if (_controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController = _controller.platform as AndroidWebViewController;

      androidController.setOnShowFileSelector((params) async {
        print("console.log：接收到的类型 ${params.acceptTypes}");
        print("console.log：接收到 multiple参数 mode：${params.mode}"); // FileSelectorMode.open 为单选、FileSelectorMode.openMultiple 为多选
        print("console.log：接收到 capture参数 是否为打开相机 ${params.isCaptureEnabled}");
        if (params.acceptTypes.contains('image/*')) {
          return _openGallery(params.isCaptureEnabled);
        }
        List<String> acceptTypes = params.acceptTypes.map((ext) => ext.replaceFirst('.', '')).toList();
        return _openFile(acceptTypes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebView File Picker')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
