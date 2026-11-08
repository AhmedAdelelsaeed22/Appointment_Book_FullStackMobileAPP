class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([this.message = 'Unauthorized']);

  @override
  String toString() {
    return message;
  }
}
