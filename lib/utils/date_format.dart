/// Dates au format JJ/MM/AAAA, celui du champ « Anniversaire ».
String formatDate(DateTime date) =>
    '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

/// Lit une date JJ/MM/AAAA ; `null` si le texte n'est pas une date valide.
DateTime? parseDate(String text) {
  final parts = text.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;

  final date = DateTime(year, month, day);
  // DateTime « corrige » les dates impossibles (31/02 devient 03/03) : on les refuse.
  return date.day == day && date.month == month ? date : null;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
