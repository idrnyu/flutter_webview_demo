import 'package:flutter/material.dart';
// import 'dart:io' show Platform;
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
      allowMultiple: false, // 是否允许多选 @TODO
      // type: FileType.image, // image
      type: FileType.custom, // 自定义类型
      allowedExtensions: acceptTypes, // 子允许自定义类型文件
      // allowedExtensions: ['pdf', 'doc'], // 只允许pdf doc类型
    );
    if (result != null && result.files.isNotEmpty) {
      print("console.log：选中的文件：${result.files}");
      String filePath = result.files.single.path!; // 获取的是单个文件 @TODO
      print("console.log: $filePath");
      Uri fileUri = Uri.file(filePath);
      return [fileUri.toString()];
    }
    print("没有选择文件");
    return [];
  }

  /// 给H5注入一些方法供H5调用
  void _injectJavaScript() {
    const token = 'teset';
    // 注入 JavaScript 方法供 H5 调用
    _controller.runJavaScript('''
      window.bridge = {};
      window.bridge.getAccessToken = function() {
        return '$token';
      };
    ''');
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          _injectJavaScript(); // 页面开始加载时就需要注入 JavaScript 代码，防止H5初始化读取不到必要的参数
        }
      ))
      // ..loadRequest(Uri.parse('http://192.168.12.137:10086/'));
      // ..loadRequest(Uri.parse('http://192.168.12.137:8080/add-government-activity?level1=1860892097729331202&level2=1861254434824790018&code=XXPX'));
      ..loadFlutterAsset('assets/index.html');

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
