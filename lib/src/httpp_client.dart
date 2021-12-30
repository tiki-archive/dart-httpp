/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';
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
  final Logger _log = Logger("HttppClient");
  static const Duration _rescheduleDelay = Duration(milliseconds: 100);
  static const Duration _closeDelay = Duration(seconds: 1);

  final String _id = Uuid().v4();
  final HttppManager _manager;
  final void Function()? _onFinish;
  final Client Function() _useClient;

  ListQueue<HttppRequest> _queue = ListQueue<HttppRequest>();
  Client? _client;
  int _pending = 0;
  int _rescheduling = 0;
  Set<String> _denySet = Set();
  Timer? _closing;
  bool _closed = false;

  HttppClient(
      {required HttppManager manager,
      void Function()? onFinish,
      Duration Function(HttppResponse)? handleRateLimit,
      Future<String> Function(HttppResponse)? handleTokenRefresh,
      Client Function()? useClient})
      : this._manager = manager,
        this._onFinish = onFinish,
        this._useClient = useClient ?? (() => Client());

  String get id => _id;

  Future<void> request(HttppRequest request) {
    _cancelClose();
    if (_queue.isEmpty) _open();
    _queue.add(request);
    _log.finest('client ${_id} queue is now ${_queue.length}');
    return _manager.add(this);
  }

  Future<void> requests(List<HttppRequest> requests) {
    _cancelClose();
    if (_queue.isEmpty) _open();
    _queue.addAll(requests);
    _log.finest('client ${_id} queue is now ${_queue.length}');
    List<Future> futures = [];
    for (HttppRequest request in requests) futures.add(_manager.add(this));
    return Future.wait(futures);
  }

  Future<void> send() async {
    HttppRequest request = _queue.removeFirst();
    try {
      if (request.isCanceled) {
        _log.fine('Request ${request.id} was cancelled');
      } else if (_denySet.isNotEmpty && _denySet.contains(request.uri.host)) {
        _log.fine('Request ${request.id} was denied');
        _reschedule(request);
      } else {
        _log.finest('Sending ${request.verb.value} ${request.uri.toString()}');
        _pending++;

        StreamedResponse streamedResponse = await _client!
            .send(request.toRequest())
            .timeout(request.timeout ?? Duration(seconds: 90))
            .onError((error, stackTrace) => throw error ??
                'client send error — ${request.verb.value} ${request.uri}');

        HttppResponse response = HttppResponse.fromResponse(
            request, await Response.fromStream(streamedResponse));
        _log.finest(
            'Received response from ${request.verb.value} ${request.uri}');

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
      if (_queue.isEmpty && _pending == 0 && _rescheduling == 0) {
        _close();
        if (_onFinish != null) _onFinish!();
      }
    }
  }

  Future<void> denyFor(HttppRequest request, Duration duration) {
    String? host = request.uri.host;
    if (!_denySet.contains(host)) {
      _log.finest("Adding $host to denylist for $duration");
      _denySet.add(host);
      Future.delayed(duration, () => _allow(host));
    }
    return _reschedule(request);
  }

  Future<void> denyUntil(HttppRequest request, Future Function() task) {
    String? host = request.uri.host;
    if (!_denySet.contains(host)) {
      _log.finest(
          "Adding $host to denylist until task ${task.hashCode} completes");
      _denySet.add(host);
      task().then((_) => _allow(host));
    }
    return _reschedule(request);
  }

  void _open() {
    if (_client == null || _closed == true) {
      _log.finest('Opening client for ${id}');
      _client = _useClient();
      _closed = false;
    }
  }

  void _close() {
    if (_client != null && (_closing == null || _closing?.isActive == false)) {
      _log.finest('Planning to close client ${id}');
      _closing = Timer(_closeDelay, () {
        _client?.close();
        _closed = true;
        _log.finest('Closed client ${id}');
      });
    }
  }

  void _cancelClose() {
    if (_closing?.isActive == true) {
      _closing?.cancel();
      _log.finest('Cancelling close client ${id}');
    }
  }

  Future<void> _reschedule(HttppRequest request) async {
    _log.fine('Request ${request.id} will be rescheduled');
    _rescheduling++;
    return Future.delayed(_rescheduleDelay, () {
      _log.fine('Request ${request.id} rescheduled');
      this.request(request);
      _rescheduling--;
    });
  }

  void _allow(String? host) {
    if (host != null && _denySet.contains(host)) {
      _log.finest("Removing $host from denylist");
      _denySet.remove(host);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is HttppClient &&
      runtimeType == other.runtimeType &&
      _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
