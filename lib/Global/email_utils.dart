import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';

Future<File> createZipFile(List<File> files) async {
  final archive = Archive();

  for (var file in files) {
    final bytes = await file.readAsBytes();
    archive.addFile(ArchiveFile(file.uri.pathSegments.last, bytes.length, bytes));
  }

  final zipEncoder = ZipEncoder();
  final zipData = zipEncoder.encode(archive)!;

  final dir = await getTemporaryDirectory();
  final zipFile = File('${dir.path}/files_bundle.zip');
  await zipFile.writeAsBytes(zipData);

  return zipFile;
}



Future<void> sendEmailWithAttachment(String address, File zipFile) async {
  bool exist = await zipFile.exists();
  print("exist: $exist");
  final Email email = Email(
    body: '请查收附件',
    subject: '测试数据',
    recipients: [address],
    attachmentPaths: [zipFile.path],
    isHTML: false,
  );



  await FlutterEmailSender.send(email);
}

// Future<void> sendEmailWithFile()