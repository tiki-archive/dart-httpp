/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

void main() {
  test('single http request', () async {
    final HttppClient client = Httpp().client();
    HttppRequest request = HttppRequest(
        uri: Uri.parse("https://google.com"),
        verb: HttppVerb.GET,
        onSuccess: (response) {
          expect(response is HttppResponse, true);
          expect(response.statusCode, 200);
        });
    await client.request(request);
  });

  test('100 simultaneous http requests', () async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord record) =>
        print('${record.level.name} [${record.loggerName}] ${record.message}'));

    int resultCount = 0;
    final HttppClient client = Httpp().client(onFinished: () {
      expect(resultCount, 100);
    });

    List<Future> requests = [];
    for (int i = 0; i < 100; i++) {
      HttppRequest request = HttppRequest(
          uri: Uri.parse("https://google.com"),
          verb: HttppVerb.GET,
          onResult: (response) {
            resultCount++;
            expect(response is HttppResponse, true);
            expect(response.statusCode, 200);
          });
      requests.add(client.request(request));
    }
    await Future.wait(requests);
  });
}
