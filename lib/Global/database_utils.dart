import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 测试语音资源 (speechresources)
class SpeechResource {
  int? id;
  String? name;
  int? tableId;
  int? wordIndex;
  String? keywords;
  int? keywordNumber;

  SpeechResource(
      {this.id,
      this.name,
      this.tableId,
      this.wordIndex,
      this.keywordNumber,
      this.keywords});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'tableId': tableId,
        'wordIndex': wordIndex,
        'keywordNumber': keywordNumber,
        'keywords': keywords
      };
  factory SpeechResource.fromMap(Map<String, dynamic> map) => SpeechResource(
      id: map['id'],
      name: map['name'],
      tableId: map['tableId'],
      wordIndex: map['wordIndex'],
      keywordNumber: map['keywordNumber'],
      keywords: map['keywords']);
}

// 测试图表 (speechtables)
class SpeechTable {
  int? id;
  String? type;
  String? resources;
  int? resourceNumber;

  SpeechTable({this.id, this.type, this.resources, this.resourceNumber});

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'resources': resources,
        'resourceNumber': resourceNumber
      };
  factory SpeechTable.fromMap(Map<String, dynamic> map) => SpeechTable(
      id: map['id'],
      type: map['type'],
      resources: map['resources'],
      resourceNumber: map['resourceNumber']);
}

// 测试记录 (testrecords)
class TestRecord {
  int? id;
  int subjectId;
  int? interviewerId;
  String? accuracy;
  String? mode;
  String? createTime;
  int? audiogramLeftId;
  int? audiogramRightId;
  int? diagnosisId;
  String? hearingStatus;
  String? hearingaidType;
  String? hearingaidSNBar;
  String? corpusType;
  String? environment;
  int? tableId;
  int? playVolume;
  String? result;

  TestRecord(
      {this.id,
      required this.subjectId,
      this.interviewerId,
      this.mode,
      this.createTime,
      this.accuracy,
      this.audiogramLeftId,
      this.audiogramRightId,
      this.diagnosisId,
      this.hearingStatus,
      this.hearingaidType,
      this.hearingaidSNBar,
      this.corpusType,
      this.environment,
      this.tableId,
      this.playVolume,
      this.result});

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'interviewerId': interviewerId,
        'mode': mode,
        'accuracy': accuracy,
        'createTime': createTime,
        'audiogramLeftId': audiogramLeftId,
        'audiogramRightId': audiogramRightId,
        'diagnosisId': diagnosisId,
        'hearingStatus': hearingStatus,
        'hearingaidType': hearingaidType,
        'hearingaidSNBar': hearingaidSNBar,
        'corpusType': corpusType,
        'environment': environment,
        'tableId': tableId,
        'playVolume': playVolume,
        'result': result
      };
  factory TestRecord.fromMap(Map<String, dynamic> map) => TestRecord(
      id: map['id'],
      subjectId: map['subjectId'],
      interviewerId: map['interviewerId'],
      mode: map['mode'],
      accuracy: map['accuracy'],
      createTime: map['createTime'],
      audiogramLeftId: map['audiogramLeftId'],
      audiogramRightId: map['audiogramRightId'],
      diagnosisId: map['diagnosisId'],
      hearingStatus: map['hearingStatus'],
      hearingaidType: map['hearingaidType'],
      hearingaidSNBar: map['hearingaidSNBar'],
      corpusType: map['corpusType'],
      environment: map['environment'],
      tableId: map['tableId'],
      playVolume: map['playVolume'],
      result: map['result']);
}

// 被试者 (subjects)
class Subject {
  int? id;
  int? organizationId;
  int? teamId;
  int? teamIndex;
  String name;
  String? gender;
  String? birthDate;
  String? phoneNumber;
  String? putonghuaLevel;
  String? wearLog;

  Subject(
      {this.id,
      this.organizationId,
      this.teamId,
      this.teamIndex,
      required this.name,
      this.gender,
      this.birthDate,
      this.phoneNumber,
      this.putonghuaLevel,
      this.wearLog});

  Map<String, dynamic> toMap() {
    if (id == null) {
      return {
        'organizationId': organizationId,
        'teamId': teamId,
        'teamIndex': teamIndex,
        'name': name,
        'gender': gender,
        'birthDate': birthDate,
        'phoneNumber': phoneNumber,
        'putonghuaLevel': putonghuaLevel,
        'wearLog': wearLog
      };
    } else {
      return {
        'id': id,
        'organizationId': organizationId,
        'teamId': teamId,
        'teamIndex': teamIndex,
        'name': name,
        'gender': gender,
        'birthDate': birthDate,
        'phoneNumber': phoneNumber,
        'putonghuaLevel': putonghuaLevel,
        'wearLog': wearLog
      };
    }
  }

  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
      id: map['id'],
      organizationId: map['organizationId'],
      teamId: map['teamId'],
      teamIndex: map['teamIndex'],
      name: map['name'],
      gender: map['gender'],
      birthDate: map['birthDate'],
      phoneNumber: map['phoneNumber'],
      putonghuaLevel: map['putonghuaLevel'],
      wearLog: map['wearLog']);
}

// 具体诊断 (diagnoses)
class Diagnosis {
  int? id;
  int? subjectId;
  int? interviewerId;
  String? createTime;
  String? description;

  Diagnosis(
      {this.id,
      this.subjectId,
      this.interviewerId,
      this.createTime,
      this.description});

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'interviewerId': interviewerId,
        'createTime': createTime,
        'description': description
      };
  factory Diagnosis.fromMap(Map<String, dynamic> map) => Diagnosis(
      id: map['id'],
      subjectId: map['subjectId'],
      interviewerId: map['interviewerId'],
      createTime: map['createTime'],
      description: map['description']);
}

// 听力图 (audiograms)
class Audiogram {
  int? id;
  int? subjectId;
  int? interviewerId;
  String? createTime;
  String? ear;
  String? data;

  Audiogram(
      {this.id,
      this.subjectId,
      this.interviewerId,
      this.createTime,
      this.ear,
      this.data});

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'interviewerId': interviewerId,
        'createTime': createTime,
        'ear': ear,
        'data': data
      };
  factory Audiogram.fromMap(Map<String, dynamic> map) => Audiogram(
      id: map['id'],
      subjectId: map['subjectId'],
      interviewerId: map['interviewerId'],
      createTime: map['createTime'],
      ear: map['ear'],
      data: map['data']);
}

// 单位 (organizations)
class Organization {
  int? id;
  String? name;
  String? address;
  String? communityCode;
  String? uniqueCode;
  int? isSuperAdmin;

  Organization(
      {this.id,
      this.name,
      this.address,
      this.communityCode,
      this.uniqueCode,
      this.isSuperAdmin});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'communityCode': communityCode,
        'uniqueCode': uniqueCode,
        'isSuperAdmin': isSuperAdmin
      };
  factory Organization.fromMap(Map<String, dynamic> map) => Organization(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      communityCode: map['communityCode'],
      uniqueCode: map['uniqueCode'],
      isSuperAdmin: map['isSuperAdmin']);
}

// 团队 (teams)
class Team {
  int? id;
  int? organizationId;
  int? index;

  Team({this.id, this.organizationId, this.index});

  Map<String, dynamic> toMap() =>
      {'id': id, 'organizationId': organizationId, 'index': index};
  factory Team.fromMap(Map<String, dynamic> map) => Team(
      id: map['id'],
      organizationId: map['organizationId'],
      index: map['index']);
}

// 主试者 (aspnetusers)
class AspNetUser {
  int? id;
  String? realName;
  int? organizationId;
  int? teamId;
  int? teamIndex;
  String? uniqueCode;
  String? userName;
  String? normalizedUserName;
  String? email;
  String? normalizedEmail;
  int? emailConfirmed; // 0 for false, 1 for true
  String? passwordHash;
  String? securityStamp;
  String? concurrencyStamp;
  String? phoneNumber;
  int? phoneNumberConfirmed;
  int? twoFactorEnabled;
  String? lockoutEnd;
  int? lockoutEnabled;
  int? accessFailedCount;

  AspNetUser(
      {this.id,
      this.realName,
      this.organizationId,
      this.teamId,
      this.teamIndex,
      this.uniqueCode,
      this.userName,
      this.normalizedUserName,
      this.email,
      this.normalizedEmail,
      this.emailConfirmed,
      this.passwordHash,
      this.securityStamp,
      this.concurrencyStamp,
      this.phoneNumber,
      this.phoneNumberConfirmed,
      this.twoFactorEnabled,
      this.lockoutEnd,
      this.lockoutEnabled,
      this.accessFailedCount});

  Map<String, dynamic> toMap() {
    if (id == null) {
      return {
        'realName': realName,
        'organizationId': organizationId,
        'teamId': teamId,
        'teamIndex': teamIndex,
        'uniqueCode': uniqueCode,
        'userName': userName,
        'normalizedUserName': normalizedUserName,
        'email': email,
        'normalizedEmail': normalizedEmail,
        'emailConfirmed': emailConfirmed,
        'passwordHash': passwordHash,
        'securityStamp': securityStamp,
        'concurrencyStamp': concurrencyStamp,
        'phoneNumber': phoneNumber,
        'phoneNumberConfirmed': phoneNumberConfirmed,
        'twoFactorEnabled': twoFactorEnabled,
        'lockoutEnd': lockoutEnd,
        'lockoutEnabled': lockoutEnabled,
        'accessFailedCount': accessFailedCount
      };
    } else {
      return {
        'id': id,
        'realName': realName,
        'organizationId': organizationId,
        'teamId': teamId,
        'teamIndex': teamIndex,
        'uniqueCode': uniqueCode,
        'userName': userName,
        'normalizedUserName': normalizedUserName,
        'email': email,
        'normalizedEmail': normalizedEmail,
        'emailConfirmed': emailConfirmed,
        'passwordHash': passwordHash,
        'securityStamp': securityStamp,
        'concurrencyStamp': concurrencyStamp,
        'phoneNumber': phoneNumber,
        'phoneNumberConfirmed': phoneNumberConfirmed,
        'twoFactorEnabled': twoFactorEnabled,
        'lockoutEnd': lockoutEnd,
        'lockoutEnabled': lockoutEnabled,
        'accessFailedCount': accessFailedCount
      };
    }
  }

  factory AspNetUser.fromMap(Map<String, dynamic> map) => AspNetUser(
      id: map['id'],
      realName: map['realName'],
      organizationId: map['organizationId'],
      teamId: map['teamId'],
      teamIndex: map['teamIndex'],
      uniqueCode: map['uniqueCode'],
      userName: map['userName'],
      normalizedUserName: map['normalizedUserName'],
      email: map['email'],
      normalizedEmail: map['normalizedEmail'],
      emailConfirmed: map['emailConfirmed'],
      passwordHash: map['passwordHash'],
      securityStamp: map['securityStamp'],
      concurrencyStamp: map['concurrencyStamp'],
      phoneNumber: map['phoneNumber'],
      phoneNumberConfirmed: map['phoneNumberConfirmed'],
      twoFactorEnabled: map['twoFactorEnabled'],
      lockoutEnd: map['lockoutEnd'],
      lockoutEnabled: map['lockoutEnabled'],
      accessFailedCount: map['accessFailedCount']);
}

// 主试者对应权限 (aspnetuserroles)
class AspNetUserRole {
  int userId;
  int roleId;

  AspNetUserRole({required this.userId, required this.roleId});

  Map<String, dynamic> toMap() => {'userId': userId, 'roleId': roleId};
  factory AspNetUserRole.fromMap(Map<String, dynamic> map) =>
      AspNetUserRole(userId: map['userId'], roleId: map['roleId']);
}

// 权限定义 (aspnetroles)
class AspNetRole {
  int? id;
  String? name;
  String? normalizedName;
  String? concurrencyStamp;

  AspNetRole({this.id, this.name, this.normalizedName, this.concurrencyStamp});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'normalizedName': normalizedName,
        'concurrencyStamp': concurrencyStamp
      };
  factory AspNetRole.fromMap(Map<String, dynamic> map) => AspNetRole(
      id: map['id'],
      name: map['name'],
      normalizedName: map['normalizedName'],
      concurrencyStamp: map['concurrencyStamp']);
}

// 设备校准记录 (devicecalibrations)
class DeviceCalibration {
  int? id;
  String? testingDevice;
  String? testedDevice;
  String? createTime;
  double? playVolume;
  int? microphoneCalibrationValue;
  int? speakerCalibrationValue;

  DeviceCalibration(
      {this.id,
      this.testingDevice,
      this.testedDevice,
      this.createTime,
      this.playVolume,
      this.microphoneCalibrationValue,
      this.speakerCalibrationValue});

  Map<String, dynamic> toMap() => {
        'id': id,
        'testingDevice': testingDevice,
        'testedDevice': testedDevice,
        'createTime': createTime,
        'playVolume': playVolume,
        'microphoneCalibrationValue': microphoneCalibrationValue,
        'speakerCalibrationValue': speakerCalibrationValue
      };
  factory DeviceCalibration.fromMap(Map<String, dynamic> map) =>
      DeviceCalibration(
          id: map['id'],
          testingDevice: map['testingDevice'],
          testedDevice: map['testedDevice'],
          createTime: map['createTime'],
          playVolume: map['playVolume'],
          microphoneCalibrationValue: map['microphoneCalibrationValue'],
          speakerCalibrationValue: map['speakerCalibrationValue']);
}

class DatabaseHelper {
  static const version = 1;

  // Table Names
  static const String tableSubjects = 'subjects';
  static const String tableTestRecords = 'testrecords';
  static const String tableDiagnoses = 'diagnoses';
  static const String tableAudiograms = 'audiograms';
  static const String tableSpeechResources = 'speechresources';
  static const String tableSpeechTables = 'speechtables';
  static const String tableDeviceCalibrations = 'devicecalibrations';
  static const String tableOrganizations = 'organizations';
  static const String tableTeams = 'teams';
  static const String tableAspNetUsers = 'aspnetusers';
  static const String tableAspNetRoles = 'aspnetroles';
  static const String tableAspNetUserRoles = 'aspnetuserroles';

  Database? _database;
  String? _currentUserId;
  String? db_path;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) return _database!;

    // 用户名为null，直接返回null
    if (_currentUserId == null) {
      return null;
    }

    // 如果用户名已设置但 _database 为空，则进行初始化
    _database = await _initDatabase(_currentUserId!);
    return _database!;
  }

  // 通过用户名初始化
  Future<void> init(String userId) async {
    if (_database != null && _currentUserId != userId) {
      await close();
    }

    _currentUserId = userId;
    _database = await _initDatabase(userId);

    // await defaultOperation();
  }

  // 初始化用户数据库
  Future<Database> _initDatabase(String userId) async {
    String dbName = 'user_$userId.db';
    String path = join(await getDatabasesPath(), dbName);

    db_path = path;

    return await openDatabase(
      path,
      version: version,
      onCreate: _onCreate,
    );
  }

  // 关闭数据，在用户登出时调用
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _currentUserId = null;
    }
  }

  // 创建数据库
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableSubjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT, organizationId INTEGER, teamId INTEGER, teamIndex INTEGER, name TEXT NOT NULL,
        gender TEXT, birthDate TEXT, phoneNumber TEXT, putonghuaLevel TEXT, wearLog TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTestRecords (
        id INTEGER PRIMARY KEY AUTOINCREMENT, subjectId INTEGER NOT NULL, interviewerId INTEGER,
        mode TEXT, accuracy TEXT, createTime TEXT, audiogramLeftId INTEGER, audiogramRightId INTEGER,
        diagnosisId INTEGER, hearingStatus TEXT, hearingaidType TEXT, hearingaidSNBar TEXT,
        corpusType TEXT, environment TEXT, tableId INTEGER, playVolume INTEGER, result TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDiagnoses (
        id INTEGER PRIMARY KEY AUTOINCREMENT, subjectId INTEGER, interviewerId INTEGER,
        createTime TEXT, description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAudiograms (
        id INTEGER PRIMARY KEY AUTOINCREMENT, subjectId INTEGER, interviewerId INTEGER,
        createTime TEXT, ear TEXT, data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSpeechResources (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, tableId INTEGER, wordIndex INTEGER, keywordNumber INTEGER, keywords TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSpeechTables (
        id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, resources TEXT, resourceNumber INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDeviceCalibrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT, testingDevice TEXT, testedDevice TEXT, createTime TEXT, playVolume REAL,
        microphoneCalibrationValue INTEGER, speakerCalibrationValue INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrganizations (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, communityCode TEXT,
        uniqueCode TEXT, isSuperAdmin INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTeams (
        id INTEGER PRIMARY KEY AUTOINCREMENT, organizationId INTEGER, "index" INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAspNetUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT, realName TEXT, organizationId INTEGER, teamId INTEGER,
        teamIndex INTEGER, uniqueCode TEXT, userName TEXT, normalizedUserName TEXT, email TEXT,
        normalizedEmail TEXT, emailConfirmed INTEGER, passwordHash TEXT, securityStamp TEXT,
        concurrencyStamp TEXT, phoneNumber TEXT, phoneNumberConfirmed INTEGER, twoFactorEnabled INTEGER,
        lockoutEnd TEXT, lockoutEnabled INTEGER, accessFailedCount INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAspNetRoles (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, normalizedName TEXT, concurrencyStamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAspNetUserRoles (
        userId INTEGER NOT NULL, roleId INTEGER NOT NULL,
        PRIMARY KEY (userId, roleId)
      )
    ''');
  }

  Future<void> defaultOperation() async {
    await insertSpeechTable(
        SpeechTable(resources: "1,2,3,4", resourceNumber: 4));
    await insertSpeechTable(SpeechTable(resources: "5,6,7", resourceNumber: 3));
    await insertSpeechTable(
        SpeechTable(resources: "1,2,3,4", resourceNumber: 4));
    await insertSpeechTable(SpeechTable(resources: "5,6,7", resourceNumber: 3));
    await insertSpeechTable(
        SpeechTable(resources: "1,2,3,4", resourceNumber: 4));
    await insertSpeechTable(SpeechTable(resources: "5,6,7", resourceNumber: 3));
    await insertSpeechTable(
        SpeechTable(resources: "1,2,3,4", resourceNumber: 4));
    await insertSpeechTable(SpeechTable(resources: "5,6,7", resourceNumber: 3));
    await insertSpeechTable(
        SpeechTable(resources: "1,2,3,4", resourceNumber: 4));
    await insertSpeechTable(SpeechTable(resources: "5,6,7", resourceNumber: 3));
    await insertSpeechTable(
        SpeechTable(resources: "1,2,3,4", resourceNumber: 4));
    await insertSpeechTable(SpeechTable(resources: "5,6,7", resourceNumber: 3));
    await insertSpeechTable(
        SpeechTable(resources: "1,2,3,4", resourceNumber: 4));
    await insertSpeechTable(SpeechTable(resources: "5,6,7", resourceNumber: 3));
  }

  // 增删改查
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.insert(table, row);
    }
    return -1;
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.query(table);
    }
    return List.empty();
  }

  Future<int> update(String table, Map<String, dynamic> row, String whereCol,
      int whereArg) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db
          .update(table, row, where: '$whereCol = ?', whereArgs: [whereArg]);
    }
    return -1;
  }

  Future<int> delete(String table, String whereCol, int whereArg) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db
          .delete(table, where: '$whereCol = ?', whereArgs: [whereArg]);
    }
    return -1;
  }

  // 被试者
  Future<int> insertSubject(Subject subject) =>
      insert(tableSubjects, subject.toMap());
  Future<List<Subject>> queryAllSubjects() async {
    List results = await queryAllRows(tableSubjects);
    List<Subject> subjects = List.empty(growable: true);
    for (var i = 0; i < results.length; i++) {
      subjects.add(Subject.fromMap(results[i]));
    }
    return subjects;
  }

  Future<List<Subject>> querySubjectsByName(String name) async {
    Database? db = await instance.database;
    if (db != null) {
      List<Map<String, dynamic>> results = await db.query(
        tableSubjects,
        where: 'name LIKE ?',
        whereArgs: ['%$name%'], // %是通配符，匹配任意字符
      );
      List<Subject> subjects = results.map((e) => Subject.fromMap(e)).toList();
      return subjects;
    }
    return List.empty();
  }

  Future<List<Subject>> querySubjectsById(int id) async {
    Database? db = await instance.database;
    if (db != null) {
      List<Map<String, dynamic>> results = await db.query(
        tableSubjects,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1, // 限制只返回1条
      );

      List<Subject> subjects = results.map((e) => Subject.fromMap(e)).toList();
      return subjects;
    }
    return List.empty();
  }

  Future<int> updateSubject(Subject subject) =>
      update(tableSubjects, subject.toMap(), 'Id', subject.id!);
  Future<int> deleteSubject(int id) => delete(tableSubjects, 'Id', id);

  // 测试记录
  Future<int> insertTestRecord(TestRecord record) =>
      insert(tableTestRecords, record.toMap());
  Future<List<TestRecord>> queryAllTestRecords() async =>
      (await queryAllRows(tableTestRecords))
          .map((e) => TestRecord.fromMap(e))
          .toList();
  Future<List<TestRecord>> queryTestRecordsBySubject(int subjectId) async {
    Database? db = await instance.database;
    if (db != null) {
      var res = await db.query(tableTestRecords,
          where: 'SubjectId = ?', whereArgs: [subjectId]);
      return res.isNotEmpty
          ? res.map((e) => TestRecord.fromMap(e)).toList()
          : [];
    }
    return [];
  }

  Future<List<TestRecord>> queryTestRecordsById(int id) async {
    Database? db = await instance.database;
    if (db != null) {
      var res = await db.query(tableTestRecords,
          where: 'id = ?', whereArgs: [id], limit: 1);
      return res.isNotEmpty
          ? res.map((e) => TestRecord.fromMap(e)).toList()
          : [];
    }
    return [];
  }

  Future<int> updateTestRecord(TestRecord record) =>
      update(tableTestRecords, record.toMap(), 'Id', record.id!);
  Future<int> deleteTestRecord(int id) => delete(tableTestRecords, 'Id', id);

  // 具体诊断
  Future<int> insertDiagnosis(Diagnosis diagnosis) =>
      insert(tableDiagnoses, diagnosis.toMap());
  Future<List<Diagnosis>> queryAllDiagnoses() async =>
      (await queryAllRows(tableDiagnoses))
          .map((e) => Diagnosis.fromMap(e))
          .toList();
  Future<int> updateDiagnosis(Diagnosis diagnosis) =>
      update(tableDiagnoses, diagnosis.toMap(), 'Id', diagnosis.id!);
  Future<int> deleteDiagnosis(int id) => delete(tableDiagnoses, 'Id', id);

  // 听力图
  Future<int> insertAudiogram(Audiogram audiogram) =>
      insert(tableAudiograms, audiogram.toMap());
  Future<List<Audiogram>> queryAllAudiograms() async =>
      (await queryAllRows(tableAudiograms))
          .map((e) => Audiogram.fromMap(e))
          .toList();
  Future<int> updateAudiogram(Audiogram audiogram) =>
      update(tableAudiograms, audiogram.toMap(), 'Id', audiogram.id!);
  Future<int> deleteAudiogram(int id) => delete(tableAudiograms, 'Id', id);

  // 测试语音资源
  Future<int> insertSpeechResource(SpeechResource resource) =>
      insert(tableSpeechResources, resource.toMap());
  Future<List<SpeechResource>> queryAllSpeechResources() async =>
      (await queryAllRows(tableSpeechResources))
          .map((e) => SpeechResource.fromMap(e))
          .toList();
  Future<int> updateSpeechResource(SpeechResource resource) =>
      update(tableSpeechResources, resource.toMap(), 'Id', resource.id!);
  Future<int> deleteSpeechResource(int id) =>
      delete(tableSpeechResources, 'Id', id);

  Future<List<SpeechResource>> querySpeechResourcesByTableId(
      int tableId) async {
    Database? db = await instance.database;
    if (db != null) {
      List<Map<String, dynamic>> results = await db.query(
        tableSpeechResources,
        where: 'tableId = ?',
        whereArgs: [tableId],
        // limit: 1, // 限制只返回1条
      );

      List<SpeechResource> speechResources =
          results.map((e) => SpeechResource.fromMap(e)).toList();
      return speechResources;
    }
    return List.empty();
  }

  // 测试语音表
  Future<int> insertSpeechTable(SpeechTable table) =>
      insert(tableSpeechTables, table.toMap());
  Future<List<SpeechTable>> queryAllSpeechTables() async =>
      (await queryAllRows(tableSpeechTables))
          .map((e) => SpeechTable.fromMap(e))
          .toList();
  Future<int> updateSpeechTable(SpeechTable table) =>
      update(tableSpeechTables, table.toMap(), 'Id', table.id!);
  Future<int> deleteSpeechTable(int id) => delete(tableSpeechTables, 'Id', id);

  // 单位
  Future<int> insertOrganization(Organization org) =>
      insert(tableOrganizations, org.toMap());
  Future<List<Organization>> queryAllOrganizations() async =>
      (await queryAllRows(tableOrganizations))
          .map((e) => Organization.fromMap(e))
          .toList();
  Future<int> updateOrganization(Organization org) =>
      update(tableOrganizations, org.toMap(), 'Id', org.id!);
  Future<int> deleteOrganization(int id) =>
      delete(tableOrganizations, 'Id', id);

  // 团队
  Future<int> insertTeam(Team team) => insert(tableTeams, team.toMap());
  Future<List<Team>> queryAllTeams() async =>
      (await queryAllRows(tableTeams)).map((e) => Team.fromMap(e)).toList();
  Future<int> updateTeam(Team team) =>
      update(tableTeams, team.toMap(), 'Id', team.id!);
  Future<int> deleteTeam(int id) => delete(tableTeams, 'Id', id);

  // 主试者
  Future<int> insertAspNetUser(AspNetUser user) =>
      insert(tableAspNetUsers, user.toMap());
  Future<List<AspNetUser>> queryAllAspNetUsers() async =>
      (await queryAllRows(tableAspNetUsers))
          .map((e) => AspNetUser.fromMap(e))
          .toList();
  Future<int> updateAspNetUser(AspNetUser user) =>
      update(tableAspNetUsers, user.toMap(), 'Id', user.id!);
  Future<int> deleteAspNetUser(int id) => delete(tableAspNetUsers, 'Id', id);

  // 主试者权限
  Future<int> insertAspNetRole(AspNetRole role) =>
      insert(tableAspNetRoles, role.toMap());
  Future<List<AspNetRole>> queryAllAspNetRoles() async =>
      (await queryAllRows(tableAspNetRoles))
          .map((e) => AspNetRole.fromMap(e))
          .toList();
  Future<int> updateAspNetRole(AspNetRole role) =>
      update(tableAspNetRoles, role.toMap(), 'Id', role.id!);
  Future<int> deleteAspNetRole(int id) => delete(tableAspNetRoles, 'Id', id);

  // 权限定义
  Future<int> insertAspNetUserRole(AspNetUserRole userRole) =>
      insert(tableAspNetUserRoles, userRole.toMap());
  Future<List<AspNetUserRole>> queryAllAspNetUserRoles() async =>
      (await queryAllRows(tableAspNetUserRoles))
          .map((e) => AspNetUserRole.fromMap(e))
          .toList();
  Future<int> deleteAspNetUserRole(int userId, int roleId) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.delete(tableAspNetUserRoles,
          where: 'UserId = ? AND RoleId = ?', whereArgs: [userId, roleId]);
    }
    return -1;
  }

  // DeviceCalibrations
  Future<int> insertDeviceCalibration(DeviceCalibration cal) =>
      insert(tableDeviceCalibrations, cal.toMap());
  Future<List<DeviceCalibration>> queryAllDeviceCalibrations() async =>
      (await queryAllRows(tableDeviceCalibrations))
          .map((e) => DeviceCalibration.fromMap(e))
          .toList();

  Future<int> updateDeviceCalibration(DeviceCalibration cal) =>
      update(tableDeviceCalibrations, cal.toMap(), 'Id', cal.id!);
  Future<int> deleteDeviceCalibration(int id) =>
      delete(tableDeviceCalibrations, 'Id', id);
  Future<List<DeviceCalibration>> queryDeviceCalibrationByDevice(String testingDevice, String testedDevice) async {
    Database? db = await instance.database;
    if (db != null) {
      List<Map<String, dynamic>> results = await db.query(
        tableDeviceCalibrations,
        where: 'testingDevice = ? AND testedDevice = ?',
        whereArgs: [testingDevice, testedDevice],
        // limit: 1, // 限制只返回1条
      );

      List<DeviceCalibration> deviceCalibrations =
          results.map((e) => DeviceCalibration.fromMap(e)).toList();
      return deviceCalibrations;
    }
    return List.empty();
  }
}
