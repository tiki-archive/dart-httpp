/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'httpp_body.dart';
import 'httpp_headers.dart';
import 'httpp_response.dart';
import 'httpp_verb.dart';

class HttppRequest {
  final String _id = Uuid().v4();
  final HttppVerb _verb;
  final Uri _uri;
  final Duration? _timeout;

  HttppHeaders? headers;
  HttppBody? body;

  void Function(HttppResponse)? onSuccess;
  void Function(HttppResponse)? onResult;
  void Function(Object)? onError;

  bool _canceled = false;

  void cancel() => _canceled = true;

  bool get isCanceled => _canceled;

  String get id => _id;

  HttppVerb get verb => _verb;

  Uri get uri => _uri;

  Duration? get timeout => _timeout;

  HttppRequest(
      {required HttppVerb verb,
      required Uri uri,
      this.headers,
      this.body,
      this.onSuccess,
      this.onResult,
      this.onError,
      Duration? timeout})
      : this._verb = verb,
        this._uri = uri,
        this._timeout = timeout;

  Request toRequest() {
    Request request = Request(_verb.value!, _uri);
    if (headers != null) request.headers.addAll(headers!.map);
    if (body != null) request.body = body!.body;
    return request;
  }

  @override
  bool operator ==(Object other) =>
      other is HttppRequest &&
      runtimeType == other.runtimeType &&
      other.id == id;

  @override
  int get hashCode => id.hashCode;
}
