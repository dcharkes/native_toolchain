// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library to find native toolchains on the host machine.
library native_toolchain;

export 'src/android_ndk.dart' show androidNdk, androidNdkClang;
export 'src/clang.dart' show clang;
export 'src/system_tools.dart';
export 'src/tool.dart';
export 'src/tool_instance.dart';
export 'src/tool_requirement.dart';
export 'src/tool_resolver.dart';
