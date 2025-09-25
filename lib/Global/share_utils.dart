import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

Future<String> shareDatabaseFile(String dbPath) async {
  try {
    // 假设你的数据库名字是 my_database.db
    const dbName = 'database.db';

    File dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception("数据库文件不存在: $dbPath");
    }

    // 复制一份到临时目录（避免权限问题）
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = p.join(tempDir.path, dbName);
    await dbFile.copy(tempPath);

    // 使用 share_plus 分享
    final result = await Share.shareXFiles(
      [XFile(tempPath)],
      text: '这是我的数据库文件 $dbName',
    );
    // if (result.status == ShareResultStatus.dismissed) {
    //   return false;
    // }
    return "";
  } catch (e) {
    return e.toString();
  }
}
