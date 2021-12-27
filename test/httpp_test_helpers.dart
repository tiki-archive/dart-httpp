/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';

class HttppTestHelpers {
  static initLogs() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord record) => print(
        '${_formatLogTime(record.time)}: ${record.level.name} [${record.loggerName}] ${record.message}'));
  }

  static Future poll(bool Function() condition) async {
    await Future.delayed(Duration(milliseconds: 100), () async {
      if (condition() == false) await poll(condition);
    });
  }

  static String _formatLogTime(DateTime timestamp) {
    return timestamp.day.toString().padLeft(2, '0') +
        '/' +
        timestamp.month.toString().padLeft(2, '0') +
        '/' +
        timestamp.year.toString().replaceRange(0, 2, '') +
        " " +
        timestamp.hour.toString().padLeft(2, '0') +
        ":" +
        timestamp.minute.toString().padLeft(2, '0') +
        ":" +
        timestamp.second.toString().padLeft(2, '0') +
        "." +
        timestamp.millisecond.toString().padRight(3, '0');
  }
}
