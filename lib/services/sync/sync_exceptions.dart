/// 同步相关的自定义异常类
class SyncException implements Exception {
  final String message;
  final String? details;

  SyncException(this.message, {this.details});

  @override
  String toString() {
    return details != null ? '$message: $details' : message;
  }
}

class SyncFailedException extends SyncException {
  SyncFailedException(super.message, {super.details});
}

class ConflictDetectedException extends SyncException {
  final String conflictFileName;

  ConflictDetectedException(
    super.message,
    this.conflictFileName, {
    super.details,
  });
}

class InitializationException extends SyncException {
  InitializationException(super.message, {super.details});
}
