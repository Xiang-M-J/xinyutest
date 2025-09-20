import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';


class LocalApiService {
  /// POST /api/audiogram
  static Future<Response> post_audiogram(Map<String, dynamic> requestData) async {
    final data = {
      "success": true,
      "message": "本地模拟 POST /api/audiogram",
      "data": requestData
    };
    return Response(
      requestOptions: RequestOptions(path: '/api/audiogram'),
      data: data,
      statusCode: 200,
    );
  }

  /// GET /api/speechtable/{id}
  static Future<Response> get_speechtable(int tableId) async {
    final data = {
      "success": true,
      "message": "本地模拟 GET /api/speechtable/$tableId",
      "data": {"tableId": tableId}
    };
    return Response(
      requestOptions: RequestOptions(path: '/api/speechtable/$tableId'),
      data: data,
      statusCode: 200,
    );
  }

  /// POST /api/testrecord
  static Future<Response> post_testrecord(Map<String, dynamic> requestData) async {
    final data = {
      "success": true,
      "message": "本地模拟 POST /api/testrecord",
      "data": requestData
    };
    return Response(
      requestOptions: RequestOptions(path: '/api/testrecord'),
      data: data,
      statusCode: 200,
    );
  }

  /// GET /api/subject/{name}
  static Future<Response> get_subject(String searchName) async {
    final data = {
      "success": true,
      "message": "本地模拟 GET /api/subject/$searchName",
      "data": {"name": searchName}
    };
    return Response(
      requestOptions: RequestOptions(path: '/api/subject/$searchName'),
      data: data,
      statusCode: 200,
    );
  }

  /// GET /api/subject/{id}/testrecords
  static Future<Response> get_subject_testrecords(int subjectId) async {
    final data = {
      "success": true,
      "message": "本地模拟 GET /api/subject/$subjectId/testrecords",
      "data": [
        {"id": 1, "record": "Record A"},
        {"id": 2, "record": "Record B"}
      ]
    };
    return Response(
      requestOptions: RequestOptions(path: '/api/subject/$subjectId/testrecords'),
      data: data,
      statusCode: 200,
    );
  }

  /// GET /api/speechtable/{mode}
  static Future<Response> get_speechtable_mode(String strMode) async {
    final data = {
      "success": true,
      "message": "本地模拟 GET /api/speechtable/$strMode",
      "data": {"mode": strMode}
    };
    return Response(
      requestOptions: RequestOptions(path: '/api/speechtable/$strMode'),
      data: data,
      statusCode: 200,
    );
  }

  /// GET /api/subject
  static Future<Response> get_subjects() async {
    final data = {
      "success": true,
      "message": "本地模拟 GET /api/subject",
      "data": [
        {"id": 1, "name": "Alice"},
        {"id": 2, "name": "Bob"}
      ]
    };
    return Response(
      requestOptions: RequestOptions(path: '/api/subject'),
      data: data,
      statusCode: 200,
    );
  }

  /// DELETE /api/subject/{id}
  static Future<Response> delete_subject(int subjectId) async {
    final data = {
      "success": true,
      "message": "本地模拟 DELETE /api/subject/$subjectId",
      "data": {"id": subjectId}
    };
    return Response(
      requestOptions: RequestOptions(path: '/api/subject/$subjectId'),
      data: data,
      statusCode: 200,
    );
  }

}
