// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'system_tools.dart';

/// Prints report to [stdout] and [stderr].
void printReport(List<SystemToolSearchResult> searchAllToolResults) {
  // final searchAllTools = await SystemTools.searchAllTools;

  const green = '\u001b[32m';
  const red = '\u001b[31m';
  const resetColor = '\u001B[39m';
  final okay = '$green[√]$resetColor';
  final error = '$red[✖]$resetColor';

  for (final result in searchAllToolResults) {
    if (!result.isAvailable) {
      stderr.writeln("$error ${result.name} not found. Paths searched:");
      if (result.searchedOnPath) {
        stderr.writeln("     - If available on PATH.");
      }
      for (final uri in result.searchedInUris) {
        stderr.writeln("     - ${uri.toFilePath()}");
      }
      if (result.searchedInUris.isEmpty && !result.searchedOnPath) {
        stderr.writeln("     - (none)");
      }
    } else {
      for (final tool in result.tools) {
        final version = tool.version;
        final versionString = version != null ? ' $version' : '';
        stdout.writeln(
            "$okay ${tool.name}$versionString: ${tool.uri.toFilePath()}");
      }
    }
  }
}
