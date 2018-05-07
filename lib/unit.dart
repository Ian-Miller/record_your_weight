const UNIT_KEY = "unit";

class WeightUnit {
  const WeightUnit(this.base, this.name);

  static final WeightUnit Kg = WeightUnit(1.0,"Kg");
  static final WeightUnit Pound = WeightUnit(2.2,"Pound");

  final double base;
  final String name;

  double to(double value, WeightUnit unit) {
    return value / base * unit.base;
  }

  factory WeightUnit.of(String unitName){
    switch(unitName){
      case "Pound":
        return Pound;
      case "Kg":
        return Kg;
      default:
        throw Exception();
    }
  }
}
