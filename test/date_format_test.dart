import 'package:flutter_test/flutter_test.dart';
import 'package:miaged/utils/date_format.dart';

void main() {
  test('formatDate écrit JJ/MM/AAAA', () {
    expect(formatDate(DateTime(1993, 12, 2)), '02/12/1993');
  });

  test('parseDate lit JJ/MM/AAAA', () {
    expect(parseDate('12/12/1993'), DateTime(1993, 12, 12));
    expect(parseDate(' 01/04/2000 '), DateTime(2000, 4, 1));
  });

  test('parseDate refuse les textes et dates invalides', () {
    expect(parseDate(''), isNull);
    expect(parseDate('pas une date'), isNull);
    expect(parseDate('31/02/2000'), isNull);
    expect(parseDate('12/13/1993'), isNull);
  });
}
