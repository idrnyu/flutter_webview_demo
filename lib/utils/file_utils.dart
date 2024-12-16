import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FileUtils {
  static final ImagePicker _imagePicker = ImagePicker();

  /// 打开相册返回图片URI
  static Future<List<String>> openGallery(bool isCaptureEnabled) async {
    // source: ImageSource.gallery // 打开用户相册
    // source: ImageSource.camera // 打开摄像头
    try {
      final XFile? image = await _imagePicker.pickImage(source: isCaptureEnabled ? ImageSource.camera : ImageSource.gallery);
      if (image != null) {
        final String filePath = image.path;
        final Uri fileUri = Uri.file(filePath);
        return [fileUri.toString()];
      }
      print("没有选择图片");
      return [];
    } catch (e) {
      print("打开相册出错: $e");
      return [];
    }
  }

  /// 打开文件管理器返回文件的URI
  static Future<List<String>> openFile(List<String>? acceptTypes) async {
    try {
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
    } catch (e) {
      print("文件选择出错: $e");
      return [];
    }
  }
}
