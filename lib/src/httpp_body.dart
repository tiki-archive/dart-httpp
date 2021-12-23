/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

class HttppBody {
  final String? _body;

  HttppBody(this._body);

  HttppBody.fromJson(Map<String, dynamic>? json) : _body = jsonEncode(json);

  String get body => _body ?? '';

  Map<String, dynamic> get jsonBody => jsonDecode(_body ?? '');
}
