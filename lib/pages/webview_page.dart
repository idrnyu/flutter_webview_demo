import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../utils/file_utils.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController _controller;

  /// 给H5注入一些方法供H5调用
  void _injectJavaScript() {
    const token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOjM1MDE0ODIsInJuU3RyIjoidkJ2ODBScFB6Z21yNVFxVjNYRGFLd1hLYkNScWhSczQiLCJhY2NvdW50SWQiOiIzNTAxNDgyIn0.McdA9YhXXzLGUJ6n3FfZSZVVb-xa_MjA9q-FPddCMi0';
    // 注入 JavaScript 方法供 H5 调用
    _controller.runJavaScript('''
      window.bridge = {};
      window.bridge.getAccessToken = function() {
        return '$token';
      };
    ''');
  }

  bool _isLoading = true; // 页面加载状态

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() => _isLoading = true);
          _injectJavaScript(); // 页面开始加载时就需要注入 JavaScript 代码，防止H5初始化读取不到必要的参数
        },
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
    // ..loadRequest(Uri.parse('http://192.168.12.137:5000/wap-h5/ncr/v2?id=1836593958728019968'));
    // ..loadRequest(Uri.parse('http://192.168.12.137:8080/add-government-activity?level1=1860892097729331202&level2=1861254434824790018&code=XXPX'));
      ..loadFlutterAsset('assets/index.html');

    if (_controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController = _controller.platform as AndroidWebViewController;

      androidController.setOnShowFileSelector((params) async {
        print("console.log：接收到的类型 ${params.acceptTypes}");
        print("console.log：接收到 multiple参数 mode：${params.mode}"); // FileSelectorMode.open 为单选、FileSelectorMode.openMultiple 为多选
        print("console.log：接收到 capture参数 是否为打开相机 ${params.isCaptureEnabled}");
        if (params.acceptTypes.contains('image/*')) {
          return FileUtils.openGallery(params.isCaptureEnabled);
        }
        List<String> acceptTypes = params.acceptTypes.map((ext) => ext.replaceFirst('.', '')).toList();
        return FileUtils.openFile(acceptTypes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebView File Picker')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()), // 加载指示器
        ]
      ),
    );
  }
}

// class WebViewPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('第二页')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // 返回到上一页
//             Navigator.pop(context);
//           },
//           child: Text('返回上一页'),
//         ),
//       ),
//     );
//   }
// }
