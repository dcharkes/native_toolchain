// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_toolchain/native_toolchain.dart';
import 'package:native_toolchain/src/doctor.dart';
import 'package:test/test.dart';

void main() {
  test('smoke test', () async {
    // This should throw exceptions on whatever system we are.
    final tools = await SystemTools.searchAllTools;
    print(tools);
  });

  test('report', () async {
    final tools = await SystemTools.searchAllTools;
    printReport(tools);
  });
}
