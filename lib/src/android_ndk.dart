// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'system_tools.dart';

final androidNdkSearch = SystemToolSearchSpecification(
  name: 'Android NDK',
  versionLastPathSegment: true,
  searchUris: (List<Uri> urisSearched) async {
    final homeDir = SystemToolSearchSpecification.homeDir;
    if (Platform.isMacOS) {
      if (homeDir != null) {
        final ndkVersionsUri = homeDir.resolve('Library/Android/sdk/ndk/');
        final ndkVersionsDir = Directory.fromUri(ndkVersionsUri);
        final ndkVersions = (await ndkVersionsDir.list().toList())
            .whereType<Directory>()
            .toList();
        if (ndkVersions.isNotEmpty) {
          final uri = ndkVersions.last.uri;
          final toolchainUri =
              uri.resolve('build/cmake/android.toolchain.cmake');
          urisSearched.add(toolchainUri);
          if (await File.fromUri(toolchainUri).exists()) {
            return uri;
          }
        }
      }
      for (final path in _homebrewNdkPaths) {
        final uri = Uri.directory(path);
        final dir = Directory.fromUri(uri);
        urisSearched.add(uri);
        if (await dir.exists()) {
          return uri;
        }
      }
    } else if (Platform.isLinux) {
      if (homeDir != null) {
        final ndkBundleUri = homeDir.resolve('Android/Sdk/ndk-bundle/');
        urisSearched.add(ndkBundleUri);
        if (await Directory(ndkBundleUri.path).exists()) {
          return ndkBundleUri;
        }
      }
    } else if (Platform.isWindows) {
      if (homeDir != null) {
        final ndkBundleUri =
            homeDir.resolve('AppData/Local/Android/Sdk/ndk-bundle');
        urisSearched.add(ndkBundleUri);
        if (await Directory(ndkBundleUri.toFilePath()).exists()) {
          return ndkBundleUri;
        }
      }
    }
    return null;
  },
  extraInfo: '''
CMake 3.18 expects an ndk-bundle/platforms which was the directory layout in
Android NDK r18 and earlier.
CMake 3.20 and NDK r23 should also work together, but this is not implemented
in this repo (yet).
  ''',
  searchOnPath: false,
  lookupVersion: false,
).doSearch();

/// Default path for homebrew to install the Android NDK.
final _homebrewNdkPaths = [
  '/usr/local/Caskroom/android-ndk/21/android-ndk-r21',
  '/usr/local/Caskroom/android-ndk/20/android-ndk-r20',
  '/usr/local/Caskroom/android-ndk/19/android-ndk-r19',
];
