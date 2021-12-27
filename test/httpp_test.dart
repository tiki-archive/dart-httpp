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
    final HttppClient client = Httpp(requestLimit: 100).client(onFinish: () {
      expect(resultCount, 100);
      complete = true;
    });
    List<HttppRequest> requests = [];
    for (int i = 0; i < 100; i++) {
      requests.add(HttppRequest(
          uri: Uri.parse("https://google.com"),
          verb: HttppVerb.GET,
          onResult: (response) {
            resultCount++;
            expect(response is HttppResponse, true);
            expect(response.statusCode, 200);
          }));
    }
    client.requests(requests);
    await HttppTestHelpers.poll(() => complete);
  });

  test('queued http requests', () async {
    int resultCount = 0;
    bool complete = false;
    final HttppClient client =
        Httpp(requestLimit: 100, useClient: () => Client()).client(
            onFinish: () {
      expect(resultCount, 300);
      complete = true;
    });
    List<HttppRequest> requests = [];
    for (int i = 0; i < 300; i++) {
      requests.add(HttppRequest(
          uri: Uri.parse("https://google.com"),
          verb: HttppVerb.GET,
          onResult: (response) {
            resultCount++;
            expect(response is HttppResponse, true);
            expect(response.statusCode, 200);
          }));
    }
    client.requests(requests);
    await HttppTestHelpers.poll(() => complete);
  });

  test('cancel http request', () async {
    int resultCount = 0;
    bool complete = false;
    final HttppClient client =
        Httpp(requestLimit: 100, useClient: () => Client()).client(
            onFinish: () {
      expect(resultCount, 199);
      complete = true;
    });

    List<HttppRequest> requests = [];
    for (int i = 0; i < 199; i++) {
      requests.add(HttppRequest(
          uri: Uri.parse("https://google.com"),
          verb: HttppVerb.GET,
          onResult: (response) {
            resultCount++;
            expect(response is HttppResponse, true);
            expect(response.statusCode, 200);
          }));
    }
    HttppRequest request = HttppRequest(
        uri: Uri.parse("https://google.com"),
        verb: HttppVerb.GET,
        onResult: (response) {
          resultCount++;
          expect(response is HttppResponse, true);
          expect(response.statusCode, 200);
        });
    requests.add(request);
    client.requests(requests);
    request.cancel();
    await HttppTestHelpers.poll(() => complete);
  });

  test('http close', () async {
    bool complete = false;
    final HttppClient client = Httpp().client();
    client.request(HttppRequest(
        uri: Uri.parse("https://google.com"),
        verb: HttppVerb.GET,
        onSuccess: (response) {
          expect(response is HttppResponse, true);
          expect(response.statusCode, 200);
        }));
    await Future.delayed(Duration(seconds: 6));
    client.request(HttppRequest(
        uri: Uri.parse("https://google.com"),
        verb: HttppVerb.GET,
        onResult: (response) {
          complete = true;
        }));
    await HttppTestHelpers.poll(() => complete);
  });
}
