// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Runs a process async and captures the exit code and standard out.
Future<RunProcessResult> runProcess({
  required String executable,
  required List<String> arguments,
  Uri? workingDirectory,
  Map<String, String>? environment,
  bool throwOnFailure = true,
}) async {
  final List<String> stdoutBuffer = <String>[];
  final List<String> stderrBuffer = <String>[];
  final Completer stdoutCompleter = Completer();
  final Completer stderrCompleter = Completer();
  final Process process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory?.toFilePath(),
    environment: environment,
  );

  process.stdout.transform(utf8.decoder).listen(
    (s) {
      stdoutBuffer.add(s);
    },
    onDone: stdoutCompleter.complete,
  );
  process.stderr.transform(utf8.decoder).listen(
    (s) {
      stderrBuffer.add(s);
    },
    onDone: stderrCompleter.complete,
  );

  final int exitCode = await process.exitCode;
  await stdoutCompleter.future;
  final String stdout = stdoutBuffer.join();
  await stderrCompleter.future;
  final String stderr = stderrBuffer.join();
  final result = RunProcessResult(
    pid: process.pid,
    command: '$executable ${arguments.join(' ')}',
    exitCode: exitCode,
    stdout: stdout,
    stderr: stderr,
  );
  if (throwOnFailure && result.exitCode != 0) {
    throw Exception(result);
  }
  return result;
}

class RunProcessResult extends ProcessResult {
  final String command;

  final int _exitCode;

  // For some reason super.exitCode returns 0.
  @override
  int get exitCode => _exitCode;

  final String _stderrString;

  @override
  String get stderr => _stderrString;

  final String _stdoutString;

  @override
  String get stdout => _stdoutString;

  RunProcessResult({
    required int pid,
    required this.command,
    required int exitCode,
    required String stderr,
    required String stdout,
  })  : _exitCode = exitCode,
        _stderrString = stderr,
        _stdoutString = stdout,
        super(pid, exitCode, stdout, stderr);

  @override
  String toString() => '''command: $command
exitCode: $exitCode
stdout: $stdout
stderr: $stderr''';
}
