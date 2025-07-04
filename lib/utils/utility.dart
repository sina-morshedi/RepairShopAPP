bool isValidIPAddress(String ip) {
  final ipRegex = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$',
  );
  return ipRegex.hasMatch(ip);
}