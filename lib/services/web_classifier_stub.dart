import 'dart:typed_data';

/// Version hors web : la classification passe par ML Kit, cette fonction n'est pas utilisée.
Future<List<(String, double)>> classifyOnWeb(Uint8List bytes) async => const [];
