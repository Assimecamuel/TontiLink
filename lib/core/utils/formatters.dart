class Formatters {
  /// Formate un montant en Franc CFA (ex: 150 000 FCFA)
  static String formatFCFA(num amount) {
    final int intAmount = amount.round();
    final String str = intAmount.toString();
    final StringBuffer buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString().split('').reversed.join('');
    return '$formatted FCFA';
  }

  /// Masquage et formatage d'un numéro camerounais (+237 6XX XX XX XX)
  static String formatCameroonPhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'\s+'), '');
    if (!clean.startsWith('+237')) {
      if (clean.startsWith('237')) {
        clean = '+$clean';
      } else {
        clean = '+237 $clean';
      }
    }
    return clean;
  }
}

