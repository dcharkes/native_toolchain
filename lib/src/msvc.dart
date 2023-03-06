// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'system_tools.dart';

final msvcSearch = SystemToolSearchSpecification(
  name: 'MSVC',
  executableName: 'cl',
  searchUris: (List<Uri> urisSearched) async {
    final visualStudioUri = await _visualStudioUri;
    if (visualStudioUri != null) {
      final msvcVersionsDir =
          Directory.fromUri(visualStudioUri.resolve('VC/Tools/MSVC/'));
      final msvcVersions = (await msvcVersionsDir.list().toList())
          .whereType<Directory>()
          .toList();
      if (msvcVersions.isNotEmpty) {
        final uri = msvcVersions.last.uri.resolve('bin/Hostx64/x64/cl.exe');
        urisSearched.add(uri);
        if (await File.fromUri(uri).exists()) {
          return uri;
        }
      }
    }
    return null;
  },
  searchOnPath: true,
  lookupVersion: true,
  lookupVersionArgument: '',
  // Has no version command line argument. Reports its version on missing input.
  lookupVersionExitCode: 2,
).doSearch();

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
  final uri = Uri(path: 'C:/Program Files (x86)/');
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
