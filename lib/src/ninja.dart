// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'cmake.dart';
import 'system_tools.dart';

final ninjaSearch = SystemToolSearchSpecification(
  name: 'Ninja',
  searchUris: (List<Uri> urisSearched) async {
    if (Platform.isWindows) {
      final cmakePath = (await cmakeSearch).newest?.uri;
      if (cmakePath != null) {
        final ninjaUri = cmakePath.resolve('ninja.exe');
        urisSearched.add(ninjaUri);
        if (await File.fromUri(ninjaUri).exists()) {
          return ninjaUri;
        }
      }
    }
    return null;
  },
).doSearch();
