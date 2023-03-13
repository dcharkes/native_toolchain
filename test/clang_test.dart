// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_toolchain/src/clang.dart';
import 'package:native_toolchain/src/tool_requirement.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test('clang smoke test', () async {
    final clangResults = await clangSearch;
    print(clangResults);
    // No crash.
  });
  test('clang smoke test 2', () async {
    final requirement =
        ToolRequirement(clang, minimumVersion: Version(14, 0, 0));
    final resolved = await clang.defaultResolver!.resolve();
    final satisfied = requirement.satisfy(resolved);
    print(satisfied);
  });
}
