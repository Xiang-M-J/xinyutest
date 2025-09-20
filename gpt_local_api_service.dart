import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalApiService {
  static final LocalApiService _instance = LocalApiService._internal();
  factory LocalApiService() => _instance;
  LocalApiService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'local_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE subjects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            gender TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE test_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject_id INTEGER,
            result TEXT,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE audiograms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject_id INTEGER,
            data TEXT,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE speech_tables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mode TEXT,
            content TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE calibrations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device TEXT,
            status INTEGER
          )
        ''');
      },
    );
  }

  // ---------------------- Subjects ----------------------
  Future<int> addSubject(Map<String, dynamic> subject) async {
    final db = await database;
    return await db.insert('subjects', subject);
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    return await db.query('subjects');
  }

  Future<Map<String, dynamic>?> getSubject(int id) async {
    final db = await database;
    final res = await db.query('subjects', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    await db.delete('test_records', where: 'subject_id = ?', whereArgs: [id]);
    await db.delete('audiograms', where: 'subject_id = ?', whereArgs: [id]);
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------- Test Records ----------------------
  Future<int> postTestRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('test_records', record);
  }

  Future<List<Map<String, dynamic>>> getSubjectTestRecords(int subjectId) async {
    final db = await database;
    return await db.query('test_records',
        where: 'subject_id = ?', whereArgs: [subjectId]);
  }

  // ---------------------- Audiograms ----------------------
  Future<int> postAudiogram(Map<String, dynamic> audiogram) async {
    final db = await database;
    return await db.insert('audiograms', audiogram);
  }

  // ---------------------- Speech Tables ----------------------
  Future<List<Map<String, dynamic>>> getSpeechTable() async {
    final db = await database;
    return await db.query('speech_tables');
  }

  Future<Map<String, dynamic>?> getSpeechTableMode(String mode) async {
    final db = await database;
    final res =
        await db.query('speech_tables', where: 'mode = ?', whereArgs: [mode]);
    return res.isNotEmpty ? res.first : null;
  }

  // ---------------------- Calibration ----------------------
  Future<bool> checkIsCalibration(String device) async {
    final db = await database;
    final res =
        await db.query('calibrations', where: 'device = ?', whereArgs: [device]);
    return res.isNotEmpty && (res.first['status'] == 1);
  }

  // ---------------------- Device ----------------------
  Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      "name": "Local Device",
      "version": "1.0",
      "status": "available",
    };
  }

  Future<bool> openBluetooth() async {
    // 本地模拟
    return true;
  }

  // ---------------------- Resource ----------------------
  Future<Map<String, dynamic>?> getResource(String mode) async {
    return await getSpeechTableMode(mode);
  }

  Future<Map<String, dynamic>?> getSource(String mode) async {
    return await getSpeechTableMode(mode);
  }

  // ---------------------- SaveResult (统一处理) ----------------------
  Future<int> saveResult(Map<String, dynamic> record) async {
    return await postTestRecord(record);
  }
}
