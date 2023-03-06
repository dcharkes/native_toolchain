// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'system_tools.dart';

final clangSearch = SystemToolSearchSpecification(
  name: 'Clang',
  searchUris: (List<Uri> urisSearched) async {
    final llvmUri_ = await _llvmUri;
    if (llvmUri_ != null) {
      final clangUri = llvmUri_.resolve('bin/clang.exe');
      urisSearched.add(clangUri);
      if (await File.fromUri(clangUri).exists()) {
        return clangUri;
      }
    }

    final visualStudioUri = await _visualStudioUri;
    if (visualStudioUri != null) {
      final clangUri = visualStudioUri.resolve('VC/Tools/Llvm/bin/clang.exe');
      urisSearched.add(clangUri);
      if (await File.fromUri(clangUri).exists()) {
        return clangUri;
      }
    }
    return null;
  },
).doSearch();

const _llvmPaths = [
  'C:/Program Files/LLVM/',
];

final Future<Uri?> _llvmUri = () async {
  for (final path in _llvmPaths) {
    final uri = Uri(path: path);
    if (await Directory.fromUri(uri).exists()) {
      return uri;
    }
  }
}();

/// Default install paths for Visual Studio.
final Future<Uri?> _visualStudioUri = () async {
  final programFilesX86Uri_ = await _programFilesX86Uri;
  if (programFilesX86Uri_ != null) {
    final visualStudioContainerUri =
        programFilesX86Uri_.resolve('Microsoft Visual Studio/');
    final visualStudioContainerDir =
        Directory.fromUri(visualStudioContainerUri);
    if (await visualStudioContainerDir.exists()) {
      for (final visualStudioYear in _visualStudioYears) {
        for (final visualStudioEdition in _visualStudioEditions) {
          final folderUri = visualStudioContainerUri
              .resolve('$visualStudioYear/$visualStudioEdition/');
          if (await Directory.fromUri(folderUri).exists()) {
            return folderUri;
          }
        }
      }
    }
  }
}();

final Future<Uri?> _programFilesX86Uri = () async {
  final uri = Uri(path: 'C:/Program Files/');
  if (await Directory.fromUri(uri).exists()) {
    return uri;
  }
  return null;
}();

final _visualStudioYears = [
  '2022',
  '2019',
  '2017',
  '2015',
  '2013',
];

final _visualStudioEditions = [
  'Professional',
  'Community',
  'Preview',
];
