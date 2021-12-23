/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class HttppHeaders {
  static const String Authorization = "Authorization";
  static const String Accept = "Accept";
  static const String ContentType = "Content-Type";
  static const String CacheControl = "Cache-Control";

  Map<String, String> _headers;

  HttppHeaders({Map<String, String>? provided})
      : _headers = provided != null ? provided : Map();

  HttppHeaders.typical({String? bearerToken}) : _headers = Map() {
    this
        .auth(bearerToken)
        .accept("*/*")
        .contentType("application/json")
        .cacheControl("no-cache");
  }

  Map<String, String> get map => _headers;

  HttppHeaders add(String name, String? value) {
    map[name] = value ?? '';
    return this;
  }

  HttppHeaders addAll(Map<String, String> headers) {
    map.addAll(headers);
    return this;
  }

  HttppHeaders remove(String name) {
    map.remove(name);
    return this;
  }

  HttppHeaders auth(String? token, {String prefix = "Bearer "}) {
    _headers[Authorization] = prefix + (token ?? '');
    return this;
  }

  HttppHeaders accept(String? accept) {
    _headers[Accept] = accept ?? '';
    return this;
  }

  HttppHeaders contentType(String? contentType) {
    _headers[ContentType] = contentType ?? '';
    return this;
  }

  HttppHeaders cacheControl(String? cacheControl) {
    _headers[CacheControl] = cacheControl ?? '';
    return this;
  }
}
