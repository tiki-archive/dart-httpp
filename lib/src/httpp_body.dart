/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:logging/logging.dart';

class HttppBody {
  Logger _log = Logger("HttpBody");
  final String? _body;

  HttppBody(this._body);

  HttppBody.fromJson(Map<String, dynamic>? json) : _body = jsonEncode(json);

  String get body => _body ?? '';

  Map<String, dynamic> get jsonBody {
    try {
      return jsonDecode(_body ?? '');
    } on FormatException catch (e) {
      _log.severe("Bad JSON format: ${e.message}", _body);
      return {};
    }catch(e){
      _log.severe(e.toString(), _body);
      return {};
    }
  }
}
