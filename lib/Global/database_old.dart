// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
//   static Database? _database;

//   DatabaseHelper._privateConstructor();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database?> _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, 'user_databases');
//     // 确保目录存在
//     await Directory(path).create(recursive: true);
//     return null;
//   }

//   // 检查用户是否有对应的数据库，没有则创建
//   Future<Database> getOrCreateUserDatabase(String userId) async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String dbPath = join(documentsDirectory.path, 'user_databases', '$userId.db');

//     bool exists = await File(dbPath).exists();
//     if (!exists) {
//       // 数据库不存在，创建数据库和表
//       Database db = await openDatabase(
//         dbPath,
//         version: 1,
//         onCreate: (Database db, int version) async {
//           // 创建 TestTable
//           await db.execute('''
//             CREATE TABLE speechresources (
//               id INTEGER PRIMARY KEY,
//               Name TEXT,
//               TableId INTEGER,
//               WordIndex INTEGER,
//             )
//           ''');
//           // 创建 Product 表
//           await db.execute('''
//             CREATE TABLE Product (
//               id INTEGER PRIMARY KEY,
//               productName TEXT,
//               productPrice REAL,
//               productDescription TEXT
//             )
//           ''');
//           // 创建其他表...（根据你提供的表结构依次创建）
//           // 这里仅为示例，你需要根据实际图中的表结构补充完整
//         },
//       );
//       return db;
//     } else {
//       // 数据库存在，直接打开
//       return await openDatabase(dbPath);
//     }
//   }
// }
