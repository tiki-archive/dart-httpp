/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:collection';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../httpp.dart';
import 'httpp_manager.dart';
import 'httpp_request.dart';
import 'httpp_response.dart';
import 'httpp_utils.dart';

class HttppClient {
  Logger _log = Logger("HttppClient");
  final String _id = Uuid().v4();

  final HttppManager _manager;
  final void Function()? _onFinished;
  ListQueue<HttppRequest> _queue = ListQueue<HttppRequest>();
  Client Function() _useClient;
  Client? _client;

  int _pending = 0;

  HttppClient(
      {required HttppManager manager,
      void Function()? onFinished,
      Client Function()? useClient})
      : this._manager = manager,
        this._onFinished = onFinished,
        this._useClient = useClient ?? (() => Client());
  String get id => _id;

  Future<void> request(HttppRequest request) {
    if (_queue.isEmpty) _open();
    _queue.add(request);
    return _manager.add(this);
  }

  void _open() {
    _log.finest('Opening client for ${id}');
    _client = _useClient();
  }

  Future<void> send() async {
    HttppRequest request = _queue.removeFirst();
    try {
      if (request.isCanceled) {
        _log.info('Request ${request.id} was cancelled');
      } else {
        _log.finest('Sending ${request.verb} ${request.uri.toString()}');
        _pending++;

        StreamedResponse streamedResponse = await _client!
            .send(request.toRequest())
            .timeout(request.timeout ?? Duration(seconds: 90))
            .onError((error, stackTrace) => throw error ??
                'client send error — ${request.verb} ${request.uri}');

        HttppResponse response = HttppResponse.fromResponse(
            request, await Response.fromStream(streamedResponse));

        _pending--;
        if (HttppUtils.is2xx(response.statusCode) && request.onSuccess != null)
          request.onSuccess!(response);
        else if (request.onResult != null) request.onResult!(response);
      }
    } catch (error) {
      _pending--;
      _log.warning(error);
      if (request.onError != null) request.onError!(error);
    } finally {
      _manager.complete();
      if (_queue.isEmpty && _pending == 0) _close();
    }
  }

  void _close() {
    _log.finest('Closing client for ${id}');
    _client?.close();
    if (_onFinished != null) _onFinished!();
  }

  @override
  bool operator ==(Object other) =>
      other is HttppClient &&
      runtimeType == other.runtimeType &&
      _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
