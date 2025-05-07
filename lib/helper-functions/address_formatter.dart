String formatAddress(String? fullAddress) {
  if (fullAddress == null) return 'Loading...';

  // Split the address by commas
  final parts = fullAddress.split(',');

  // If we have less than 2 parts, return the original address
  if (parts.length < 2) return fullAddress;

  // Take the first two meaningful parts of the address
  // and remove any numeric codes or coordinates
  final meaningfulParts = parts
      .take(2)
      .map((part) => part.trim())
      .map((part) => part.replaceAll(RegExp(r'\d+\+[A-Z]+|\d+'), '').trim())
      .where((part) => part.isNotEmpty)
      .toList();

  // Join the parts with a comma
  return meaningfulParts.join(', ');
}
