/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:http/http.dart';

import 'httpp_body.dart';
import 'httpp_headers.dart';
import 'httpp_request.dart';

class HttppResponse {
  HttppRequest? request;
  int? statusCode;
  String? reasonPhrase;
  int? contentLength;
  HttppHeaders? headers;
  HttppBody? body;

  HttppResponse.name(
      {this.request,
      this.statusCode,
      this.reasonPhrase,
      this.contentLength,
      this.headers,
      this.body});

  HttppResponse.fromResponse(HttppRequest request, Response response) {
    this.request = request;
    statusCode = response.statusCode;
    reasonPhrase = response.reasonPhrase;
    contentLength = response.contentLength;
    headers = HttppHeaders(provided: response.headers);
    body = HttppBody(response.body);
  }
}
