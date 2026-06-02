import 'package:flutter_test/flutter_test.dart';
import 'package:newbank/services/validators.dart';

void main() {
  group('Validators', () {
    test('email rejects empty', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('email rejects invalid formats', () {
      expect(Validators.email('@'), isNotNull);
      expect(Validators.email('foo@'), isNotNull);
      expect(Validators.email('@bar'), isNotNull);
      expect(Validators.email('no-at-sign'), isNotNull);
      expect(Validators.email('foo@bar'), isNotNull); // no TLD
    });

    test('email accepts valid formats', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('a.b@c.de'), isNull);
      expect(Validators.email('test123@domain.co.uk'), isNull);
    });

    test('senha rejects short passwords', () {
      expect(Validators.senha(null), isNotNull);
      expect(Validators.senha('12345'), isNotNull);
    });

    test('senha accepts valid passwords', () {
      expect(Validators.senha('123456'), isNull);
      expect(Validators.senha('my-secure-pass'), isNull);
    });

    test('nomeCompleto requires first and last name', () {
      expect(Validators.nomeCompleto(null), isNotNull);
      expect(Validators.nomeCompleto(''), isNotNull);
      expect(Validators.nomeCompleto('Maria'), isNotNull);
    });

    test('nomeCompleto accepts full names', () {
      expect(Validators.nomeCompleto('Maria Silva'), isNull);
      expect(Validators.nomeCompleto('João Pedro Santos'), isNull);
    });
  });
}
