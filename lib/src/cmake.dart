// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'system_tools.dart';

final cmakeSearch = SystemToolSearchSpecification(
  name: 'CMake',
  searchUris: (List<Uri> urisSearched) async {
    final homeDir = SystemToolSearchSpecification.homeDir;
    if (Platform.isWindows) {
      if (homeDir != null) {
        final cmakeUri = homeDir.resolve('AppData/Local/Android/Sdk/cmake/');
        final cmakeDir = Directory(cmakeUri.toFilePath());
        urisSearched.add(cmakeUri);
        if (await cmakeDir.exists()) {
          final cmakeVersions =
              (await cmakeDir.list().toList()).whereType<Directory>().toList();
          if (cmakeVersions.isNotEmpty) {
            return cmakeVersions.last.uri.resolve('bin/cmake.exe');
          }
        }
      }
    }
    if (Platform.isMacOS) {
      final cmakeUri = Uri.parse('/Applications/CMake.app/Contents/bin/cmake');
      urisSearched.add(cmakeUri);
      final cmakeFile = File.fromUri(cmakeUri);
      if (await cmakeFile.exists()) {
        return cmakeUri;
      }
    }
    return null;
  },
).doSearch();
