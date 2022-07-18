import 'package:flutter_test/flutter_test.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

void main() {
  test('HTML in HttppBody jsonBody logs an error with full html data', () {
    List<LogRecord> messages = [];
    Logger.root.onRecord.listen((event) => messages.add(event));
    HttppBody body = HttppBody('<!DOCTYPE html><html lang="en"><head>"');
    dynamic jsonBody = body.jsonBody;
    expect(jsonBody, {});
    expect(messages.length, 1);
    expect(messages[0].message, 'Bad JSON format: Unexpected character');
    expect(messages[0].error, '<!DOCTYPE html><html lang="en"><head>"');
  });

  test('HTTPBody parses maps, strings and lists', () {
    HttppBody mapBody = HttppBody('{"key":"value"}');
    HttppBody ListBody = HttppBody('[1,2,3]');
    dynamic map = mapBody.jsonBody;
    dynamic list = ListBody.jsonBody;
    expect(list[0], 1);
    expect(map['key'], "value");
  });
}