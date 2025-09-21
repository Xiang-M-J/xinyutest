import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtils {
  // 计算 MD5 哈希值
  static String md5Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // 计算 SHA-1 哈希值
  static String sha1Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  // 计算 SHA-256 哈希值
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 计算带盐值的哈希（更安全）
  static String hashWithSalt(String input, String salt) {
    // 将盐值与输入拼接后计算哈希
    final saltedInput = '$input:$salt';
    final bytes = utf8.encode(saltedInput);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}