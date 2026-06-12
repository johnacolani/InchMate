import 'package:fraction/fraction.dart';

class ConvertUnitsUseCase {
  String execute(Fraction inches, bool isSquare) {
    // Compute the magnitude and apply the sign once, so negative values don't
    // produce inconsistent whole/decimal parts.
    final negative = inches.toDouble() < 0;
    final sign = negative ? '-' : '';
    final absInches = negative ? inches * Fraction(-1) : inches;

    if (isSquare) {
      final totalSqIn = absInches.toDouble();
      final wholeSqFt = (totalSqIn / 144).floor();
      final remainderSqIn = totalSqIn % 144;

      // Correctly compute decimal part using 144
      final decimalPart = remainderSqIn / 144;

      // Format to 3 decimal places
      final formattedDecimal = decimalPart.toStringAsFixed(3);

      return "$sign$wholeSqFt.${formattedDecimal.split('.')[1]} sq ft";
    } else {
      // Existing linear conversion
      final wholeFeet = (absInches / Fraction(12)).toDouble().truncate();
      final remainderInches = absInches - Fraction(wholeFeet * 12);

      return "$sign$wholeFeet ft ${formatFraction(remainderInches)} in";
    }
  }

  String formatFraction(Fraction fraction) {
    fraction = fraction.reduce();
    final integerPart = fraction.toDouble().truncate();
    final fractionalPart = fraction - Fraction(integerPart);

    return integerPart == 0
        ? fraction.toString()
        : "$integerPart ${fractionalPart.toString()}";
  }
}