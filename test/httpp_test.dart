/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:httpp/httpp.dart';

import 'httpp_test_helpers.dart';

void main() {
  setUp(() {
    HttppTestHelpers.initLogs();
  });

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
    int resultCount = 0;
    bool complete = false;
    final HttppClient client = Httpp(requestLimit: 100).client(onFinished: () {
      expect(resultCount, 100);
      complete = true;
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
    await HttppTestHelpers.poll(() => complete);
  });

  test('queued http requests', () async {
    int resultCount = 0;
    bool complete = false;
    final HttppClient client =
        Httpp(requestLimit: 100, useClient: () => Client()).client(
            onFinished: () {
      expect(resultCount, 300);
      complete = true;
    });

    List<Future> requests = [];
    for (int i = 0; i < 300; i++) {
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
    await HttppTestHelpers.poll(() => complete);
  });

  test('cancel http request', () async {
    int resultCount = 0;
    bool complete = false;
    final HttppClient client =
        Httpp(requestLimit: 100, useClient: () => Client()).client(
            onFinished: () {
      expect(resultCount, 199);
      complete = true;
    });

    List<Future> requests = [];
    for (int i = 0; i < 199; i++) {
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
    HttppRequest request = HttppRequest(
        uri: Uri.parse("https://google.com"),
        verb: HttppVerb.GET,
        onResult: (response) {
          resultCount++;
          expect(response is HttppResponse, true);
          expect(response.statusCode, 200);
        });
    requests.add(client.request(request));
    request.cancel();
    await HttppTestHelpers.poll(() => complete);
  });
}
