/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

enum HttppVerb { GET, POST, PUT, DELETE, HEAD, PATCH, OPTIONS, TRACE, CONNECT }

extension HttpVerbExt on HttppVerb {
  String? get value {
    switch (this) {
      case HttppVerb.GET:
        return "GET";
      case HttppVerb.POST:
        return "POST";
      case HttppVerb.PUT:
        return "PUT";
      case HttppVerb.DELETE:
        return "DELETE";
      case HttppVerb.HEAD:
        return "HEAD";
      case HttppVerb.PATCH:
        return "PATCH";
      case HttppVerb.OPTIONS:
        return "OPTIONS";
      case HttppVerb.TRACE:
        return "TRACE";
      case HttppVerb.CONNECT:
        return "CONNECT";
      default:
        return null;
    }
  }
}
