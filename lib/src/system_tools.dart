// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import 'android_ndk.dart';
import 'clang.dart';
import 'cmake.dart';
import 'msvc.dart';
import 'ninja.dart';
import 'tool.dart';
import 'tool_instance.dart';
import 'utils/run_process.dart';
import 'utils/sem_version.dart';

abstract class SystemTools {
  static final Future<ToolInstance> androidNdk =
      androidNdkSearch.then((e) => e.newestOrThrow);

  static final Future<ToolInstance> clang =
      clangSearch.then((e) => e.newestOrThrow);

  static final Future<ToolInstance> cmake =
      cmakeSearch.then((e) => e.newestOrThrow);

  static final Future<ToolInstance> msvc =
      msvcSearch.then((e) => e.newestOrThrow);

  static final Future<ToolInstance> ninja =
      ninjaSearch.then((e) => e.newestOrThrow);

  static final Future<List<SystemToolSearchResult>> searchAllTools =
      Future.wait([
    androidNdkSearch,
    clangSearch,
    cmakeSearch,
    if (Platform.isWindows) msvcSearch,
    ninjaSearch,
  ]);
}

class SystemToolSearchSpecification {
  final String name;
  final String? executableName;
  final bool searchOnPath;
  final Future<Uri?> Function(List<Uri>)? searchUris;
  final bool lookupVersion;
  final bool versionLastPathSegment;
  final String? lookupVersionArgument;
  final int lookupVersionExitCode;
  final String? extraInfo;

  SystemToolSearchSpecification({
    required this.name,
    this.executableName,
    this.searchOnPath = true,
    this.searchUris,
    this.lookupVersion = true,
    this.versionLastPathSegment = false,
    this.lookupVersionArgument,
    this.extraInfo,
    this.lookupVersionExitCode = 0,
  });

  Future<SystemToolSearchResult> doSearch() async {
    Uri? uri;
    var executableName = this.executableName;
    final searchUris = this.searchUris;
    final lookupVersionArgument = this.lookupVersionArgument;
    if (searchOnPath) {
      executableName ??= name.toLowerCase();
      uri = await which(executableName);
    }
    final searchedInUris = <Uri>[];
    if (uri == null && searchUris != null) {
      uri = await searchUris(searchedInUris);
    }
    Version? version;
    if (lookupVersion && uri != null) {
      version = await executableVersion(
        uri,
        argument: lookupVersionArgument,
        expectedExitCode: lookupVersionExitCode,
      );
    }
    if (versionLastPathSegment && uri != null) {
      final versionString = uri.pathSegments.where((e) => e != '').last;
      version = versionFromString(versionString);
    }
    return SystemToolSearchResult(
      name: name,
      tools: [
        if (uri != null)
          ToolInstance(tool: Tool(name: name), uri: uri, version: version)
      ],
      searchedOnPath: searchOnPath,
      searchedInUris: searchedInUris,
      extraInfo: extraInfo,
    );
  }

  /// Try different environment variables for finding the home directory.
  ///
  /// The $HOME in powershell does not show up in Dart.
  static final Uri? homeDir = () {
    final path =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (path == null) return null;
    return Directory(path).uri;
  }();

  /// Finds an executable available on the `PATH`.
  ///
  /// Adds `.exe` on Windows.
  static Future<Uri?> which(String executableName) async {
    final whichOrWhere = Platform.isWindows ? 'where' : 'which';
    final fileExtension = Platform.isWindows ? '.exe' : '';
    final process = await runProcess(
      executable: whichOrWhere,
      arguments: ['$executableName$fileExtension'],
      throwOnFailure: false,
    );
    if (process.exitCode == 0) {
      final file = File(LineSplitter.split(process.stdout).first);
      final uri = File(await file.resolveSymbolicLinks()).uri;
      return uri;
    }
    if (process.exitCode == 1) {
      // The exit code for executable not being on the `PATH`.
      return null;
    }
    throw ToolError(
        '`$whichOrWhere $executableName` returned unexpected exit code: '
        '${process.exitCode}.');
  }

  /// Finds the version of an [executable].
  ///
  /// Assumes the version is formatted as semantic versioning.
  ///
  /// Takes the first semantic version string as version.
  static Future<Version> executableVersion(
    Uri executable, {
    String? argument,
    int expectedExitCode = 0,
  }) async {
    argument ??= '--version';
    final executablePath = executable.toFilePath();
    final process = await runProcess(
      executable: executablePath,
      arguments: [argument],
      throwOnFailure: expectedExitCode == 0,
    );
    if (process.exitCode != expectedExitCode) {
      throw ToolError(
          '`$executablePath $argument` returned unexpected exit code: '
          '${process.exitCode}.');
    }
    return versionFromString(process.stdout)!;
  }
}

class SystemToolSearchResult {
  final String name;

  /// Tools found.
  final List<ToolInstance> tools;

  /// Searched for executable on the environment `PATH`.
  final bool searchedOnPath;

  /// Searched for the native tool in these [Uri]s.
  ///
  /// Typically default install locations for tools.
  final List<Uri> searchedInUris;

  /// Extra info regarding this native tool.
  final String? extraInfo;

  SystemToolSearchResult({
    required this.name,
    required this.tools,
    required this.searchedInUris,
    this.searchedOnPath = false,
    this.extraInfo,
  }) {
    tools.sort();
  }

  @override
  String toString() => 'SystemToolSearchResult($name, $tools)';

  bool get isAvailable => tools.isNotEmpty;

  ToolInstance? get newest {
    if (tools.isEmpty) return null;
    return tools.last;
  }

  ToolInstance get newestOrThrow {
    final newest = this.newest;
    if (newest == null) {
      String message = 'Could not find $name.';
      if (searchedOnPath) {
        message += '\nSearched on environment PATH.';
      }
      if (searchedInUris.isNotEmpty) {
        message += '\nSearched in $searchedInUris';
      }
      if (extraInfo != null) {
        message += '\n$extraInfo';
      }
      throw ToolError(message);
    }
    return newest;
  }
}

/// The operation could not be performed due to a configuration error on the
/// host system.
class ToolError extends Error {
  final String message;
  ToolError(this.message);
  @override
  String toString() => "System not configured correctly: $message";
}
