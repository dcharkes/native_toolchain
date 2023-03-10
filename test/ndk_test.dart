// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_toolchain/native_toolchain.dart';
import 'package:test/test.dart';

void main() {
  test('NDK smoke test', () async {
    final requirement = RequireAll([
      ToolRequirement(androidNdk),
      ToolRequirement(androidNdkClang),
    ]);
    final resolved = await androidNdk.defaultResolver!.resolve();
    final satisfied = requirement.satisfy(resolved);
    print(satisfied);
  });
}
