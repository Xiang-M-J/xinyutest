import 'dart:async';
import 'dart:io';

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
        'Id': id,
        'Name': name,
        'TableId': tableId,
        'WordIndex': wordIndex,
        'KeywordNumber': keywordNumber,
        'Keywords': keywords
      };
  factory SpeechResource.fromMap(Map<String, dynamic> map) => SpeechResource(
      id: map['Id'],
      name: map['Name'],
      tableId: map['TableId'],
      wordIndex: map['WordIndex'],
      keywordNumber: map['KeywordNumber'],
      keywords: map['Keywords']);
}

// 测试图表 (speechtables)
class SpeechTable {
  int? id;
  String? type;

  SpeechTable({this.id, this.type});

  Map<String, dynamic> toMap() => {'Id': id, 'Type': type};
  factory SpeechTable.fromMap(Map<String, dynamic> map) =>
      SpeechTable(id: map['Id'], type: map['Type']);
}

// 测试记录 (testrecords)
class TestRecord {
  int? id;
  int subjectId;
  int interviewerId;
  String? mode;
  String createTime;
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
      required this.interviewerId,
      this.mode,
      required this.createTime,
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
        'Id': id,
        'SubjectId': subjectId,
        'InterviewerId': interviewerId,
        'Mode': mode,
        'CreateTime': createTime,
        'AudiogramLeftId': audiogramLeftId,
        'AudiogramRightId': audiogramRightId,
        'DiagnosisId': diagnosisId,
        'HearingStatus': hearingStatus,
        'HearingaidType': hearingaidType,
        'HearingaidSNBar': hearingaidSNBar,
        'CorpusType': corpusType,
        'Environment': environment,
        'TableId': tableId,
        'PlayVolume': playVolume,
        'Result': result
      };
  factory TestRecord.fromMap(Map<String, dynamic> map) => TestRecord(
      id: map['Id'],
      subjectId: map['SubjectId'],
      interviewerId: map['InterviewerId'],
      mode: map['Mode'],
      createTime: map['CreateTime'],
      audiogramLeftId: map['AudiogramLeftId'],
      audiogramRightId: map['AudiogramRightId'],
      diagnosisId: map['DiagnosisId'],
      hearingStatus: map['HearingStatus'],
      hearingaidType: map['HearingaidType'],
      hearingaidSNBar: map['HearingaidSNBar'],
      corpusType: map['CorpusType'],
      environment: map['Environment'],
      tableId: map['TableId'],
      playVolume: map['PlayVolume'],
      result: map['Result']);
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
  String? listeningLevel;
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
      this.listeningLevel,
      this.wearLog});

  Map<String, dynamic> toMap() => {
        'Id': id,
        'OrganizationId': organizationId,
        'TeamId': teamId,
        'TeamIndex': teamIndex,
        'Name': name,
        'Gender': gender,
        'BirthDate': birthDate,
        'PhoneNumber': phoneNumber,
        'ListeningLevel': listeningLevel,
        'WearLog': wearLog
      };
  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
      id: map['Id'],
      organizationId: map['OrganizationId'],
      teamId: map['TeamId'],
      teamIndex: map['TeamIndex'],
      name: map['Name'],
      gender: map['Gender'],
      birthDate: map['BirthDate'],
      phoneNumber: map['PhoneNumber'],
      listeningLevel: map['ListeningLevel'],
      wearLog: map['WearLog']);
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
        'Id': id,
        'SubjectId': subjectId,
        'InterviewerId': interviewerId,
        'CreateTime': createTime,
        'Description': description
      };
  factory Diagnosis.fromMap(Map<String, dynamic> map) => Diagnosis(
      id: map['Id'],
      subjectId: map['SubjectId'],
      interviewerId: map['InterviewerId'],
      createTime: map['CreateTime'],
      description: map['Description']);
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
        'Id': id,
        'SubjectId': subjectId,
        'InterviewerId': interviewerId,
        'CreateTime': createTime,
        'Ear': ear,
        'Data': data
      };
  factory Audiogram.fromMap(Map<String, dynamic> map) => Audiogram(
      id: map['Id'],
      subjectId: map['SubjectId'],
      interviewerId: map['InterviewerId'],
      createTime: map['CreateTime'],
      ear: map['Ear'],
      data: map['Data']);
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
        'Id': id,
        'Name': name,
        'Address': address,
        'CommunityCode': communityCode,
        'UniqueCode': uniqueCode,
        'IsSuperAdmin': isSuperAdmin
      };
  factory Organization.fromMap(Map<String, dynamic> map) => Organization(
      id: map['Id'],
      name: map['Name'],
      address: map['Address'],
      communityCode: map['CommunityCode'],
      uniqueCode: map['UniqueCode'],
      isSuperAdmin: map['IsSuperAdmin']);
}

// 团队 (teams)
class Team {
  int? id;
  int? organizationId;
  int? index;

  Team({this.id, this.organizationId, this.index});

  Map<String, dynamic> toMap() =>
      {'Id': id, 'OrganizationId': organizationId, 'Index': index};
  factory Team.fromMap(Map<String, dynamic> map) => Team(
      id: map['Id'],
      organizationId: map['OrganizationId'],
      index: map['Index']);
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

  Map<String, dynamic> toMap() => {
        'Id': id,
        'RealName': realName,
        'OrganizationId': organizationId,
        'TeamId': teamId,
        'TeamIndex': teamIndex,
        'UniqueCode': uniqueCode,
        'UserName': userName,
        'NormalizedUserName': normalizedUserName,
        'Email': email,
        'NormalizedEmail': normalizedEmail,
        'EmailConfirmed': emailConfirmed,
        'PasswordHash': passwordHash,
        'SecurityStamp': securityStamp,
        'ConcurrencyStamp': concurrencyStamp,
        'PhoneNumber': phoneNumber,
        'PhoneNumberConfirmed': phoneNumberConfirmed,
        'TwoFactorEnabled': twoFactorEnabled,
        'LockoutEnd': lockoutEnd,
        'LockoutEnabled': lockoutEnabled,
        'AccessFailedCount': accessFailedCount
      };
  factory AspNetUser.fromMap(Map<String, dynamic> map) => AspNetUser(
      id: map['Id'],
      realName: map['RealName'],
      organizationId: map['OrganizationId'],
      teamId: map['TeamId'],
      teamIndex: map['TeamIndex'],
      uniqueCode: map['UniqueCode'],
      userName: map['UserName'],
      normalizedUserName: map['NormalizedUserName'],
      email: map['Email'],
      normalizedEmail: map['NormalizedEmail'],
      emailConfirmed: map['EmailConfirmed'],
      passwordHash: map['PasswordHash'],
      securityStamp: map['SecurityStamp'],
      concurrencyStamp: map['ConcurrencyStamp'],
      phoneNumber: map['PhoneNumber'],
      phoneNumberConfirmed: map['PhoneNumberConfirmed'],
      twoFactorEnabled: map['TwoFactorEnabled'],
      lockoutEnd: map['LockoutEnd'],
      lockoutEnabled: map['LockoutEnabled'],
      accessFailedCount: map['AccessFailedCount']);
}

// 主试者对应权限 (aspnetuserroles)
class AspNetUserRole {
  int userId;
  int roleId;

  AspNetUserRole({required this.userId, required this.roleId});

  Map<String, dynamic> toMap() => {'UserId': userId, 'RoleId': roleId};
  factory AspNetUserRole.fromMap(Map<String, dynamic> map) =>
      AspNetUserRole(userId: map['UserId'], roleId: map['RoleId']);
}

// 权限定义 (aspnetroles)
class AspNetRole {
  int? id;
  String? name;
  String? normalizedName;
  String? concurrencyStamp;

  AspNetRole({this.id, this.name, this.normalizedName, this.concurrencyStamp});

  Map<String, dynamic> toMap() => {
        'Id': id,
        'Name': name,
        'NormalizedName': normalizedName,
        'ConcurrencyStamp': concurrencyStamp
      };
  factory AspNetRole.fromMap(Map<String, dynamic> map) => AspNetRole(
      id: map['Id'],
      name: map['Name'],
      normalizedName: map['NormalizedName'],
      concurrencyStamp: map['ConcurrencyStamp']);
}

// // 设备校准记录 (devicecalibrations)
// class DeviceCalibration {
//   int? id;
//   String? testingDevice;
//   String? createTime;
//   double? playVolume;
//   int? microphoneCalibrationValue;
//   int? speakerCalibrationValue;

//   DeviceCalibration({this.id, this.testingDevice, this.createTime, this.playVolume, this.microphoneCalibrationValue, this.speakerCalibrationValue});

//   Map<String, dynamic> toMap() => {'Id': id, 'TestingDevice': testingDevice, 'CreateTime': createTime, 'PlayVolume': playVolume, 'MicrophoneCalibrationValue': microphoneCalibrationValue, 'SpeakerCalibrationValue': speakerCalibrationValue};
//   factory DeviceCalibration.fromMap(Map<String, dynamic> map) => DeviceCalibration(id: map['Id'], testingDevice: map['TestingDevice'], createTime: map['CreateTime'], playVolume: map['PlayVolume'], microphoneCalibrationValue: map['MicrophoneCalibrationValue'], speakerCalibrationValue: map['SpeakerCalibrationValue']);
// }

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
  }

  // 初始化用户数据库
  Future<Database> _initDatabase(String userId) async {
    String dbName = 'user_$userId.db';
    String path = join(await getDatabasesPath(), dbName);

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
        Id INTEGER PRIMARY KEY AUTOINCREMENT, OrganizationId INTEGER, TeamId INTEGER, TeamIndex INTEGER, Name TEXT NOT NULL,
        Gender TEXT, BirthDate TEXT, PhoneNumber TEXT, ListeningLevel TEXT, WearLog TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTestRecords (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, SubjectId INTEGER NOT NULL, InterviewerId INTEGER NOT NULL,
        Mode TEXT, CreateTime TEXT NOT NULL, AudiogramLeftId INTEGER, AudiogramRightId INTEGER,
        DiagnosisId INTEGER, HearingStatus TEXT, HearingaidType TEXT, HearingaidSNBar TEXT,
        CorpusType TEXT, Environment TEXT, TableId INTEGER, PlayVolume INTEGER, Result TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDiagnoses (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, SubjectId INTEGER, InterviewerId INTEGER,
        CreateTime TEXT, Description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAudiograms (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, SubjectId INTEGER, InterviewerId INTEGER,
        CreateTime TEXT, Ear TEXT, Data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSpeechResources (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, TableId INTEGER, WordIndex INTEGER, KeywordNumber: INTEGER, Keywords TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSpeechTables (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDeviceCalibrations (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, TestingDevice TEXT, CreateTime TEXT, PlayVolume REAL,
        MicrophoneCalibrationValue INTEGER, SpeakerCalibrationValue INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrganizations (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Address TEXT, CommunityCode TEXT,
        UniqueCode TEXT, IsSuperAdmin INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTeams (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, OrganizationId INTEGER, "Index" INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAspNetUsers (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, RealName TEXT, OrganizationId INTEGER, TeamId INTEGER,
        TeamIndex INTEGER, UniqueCode TEXT, UserName TEXT, NormalizedUserName TEXT, Email TEXT,
        NormalizedEmail TEXT, EmailConfirmed INTEGER, PasswordHash TEXT, SecurityStamp TEXT,
        ConcurrencyStamp TEXT, PhoneNumber TEXT, PhoneNumberConfirmed INTEGER, TwoFactorEnabled INTEGER,
        LockoutEnd TEXT, LockoutEnabled INTEGER, AccessFailedCount INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAspNetRoles (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, NormalizedName TEXT, ConcurrencyStamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAspNetUserRoles (
        UserId INTEGER NOT NULL, RoleId INTEGER NOT NULL,
        PRIMARY KEY (UserId, RoleId)
      )
    ''');
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
  Future<List<Subject>> queryAllSubjects() async =>
      (await queryAllRows(tableSubjects))
          .map((e) => Subject.fromMap(e))
          .toList();
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

  // // DeviceCalibrations
  // Future<int> insertDeviceCalibration(DeviceCalibration cal) => insert(tableDeviceCalibrations, cal.toMap());
  // Future<List<DeviceCalibration>> queryAllDeviceCalibrations() async => (await queryAllRows(tableDeviceCalibrations)).map((e) => DeviceCalibration.fromMap(e)).toList();
  // Future<int> updateDeviceCalibration(DeviceCalibration cal) => update(tableDeviceCalibrations, cal.toMap(), 'Id', cal.id!);
  // Future<int> deleteDeviceCalibration(int id) => delete(tableDeviceCalibrations, 'Id', id);
}
