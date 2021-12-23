/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'src/httpp_client.dart';
import 'src/httpp_manager.dart';

export 'src/httpp_body.dart';
export 'src/httpp_client.dart';
export 'src/httpp_headers.dart';
export 'src/httpp_request.dart';
export 'src/httpp_response.dart';
export 'src/httpp_utils.dart';
export 'src/httpp_verb.dart';

class Httpp {
  HttppManager _manager = HttppManager();

  HttppClient client({void Function()? onFinished}) =>
      HttppClient(manager: _manager, onFinished: onFinished);
}
