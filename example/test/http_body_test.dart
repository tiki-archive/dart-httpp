import 'package:flutter_test/flutter_test.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

void main() {
  test('HTML in HttppBody jsonBody logs an error with full html data', () {
    List<LogRecord> messages = [];
    Logger.root.onRecord.listen((event) => messages.add(event));
    HttppBody body = HttppBody('<!DOCTYPE html><html lang="en"><head>"');
    Map<String, dynamic>? jsonBody = body.jsonBody;
    expect(jsonBody, {});
    expect(messages.length, 1);
    expect(messages[0].message, 'Bad JSON format: Unexpected character');
    expect(messages[0].error, '<!DOCTYPE html><html lang="en"><head>"');
  });
}