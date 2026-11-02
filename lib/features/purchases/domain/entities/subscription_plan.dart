import 'package:equatable/equatable.dart';

/// Los tres planes de la suscripción Premium.
enum SubscriptionPlanType { weekly, monthly, annual }

/// Un plan de la suscripción tal como lo devuelve la tienda del sistema: el
/// precio y la moneda nunca viven en el código.
class SubscriptionPlan extends Equatable {
  final SubscriptionPlanType type;
  final String productId;

  /// Precio con el formato de la tienda y la moneda del usuario ("$14.99").
  final String displayPrice;

  /// Precio numérico, solo para calcular el ahorro entre planes.
  final double price;
  final String currencyCode;

  /// `true` solo cuando la tienda confirma que el usuario puede usar la
  /// prueba gratis. Si ya la usó o no se puede comprobar, es `false`.
  final bool isTrialEligible;

  const SubscriptionPlan({
    required this.type,
    required this.productId,
    required this.displayPrice,
    required this.price,
    required this.currencyCode,
    this.isTrialEligible = false,
  });

  @override
  List<Object?> get props => [
        type,
        productId,
        displayPrice,
        price,
        currencyCode,
        isTrialEligible,
      ];
}

/// Ahorro del plan anual frente a pagar 12 mensualidades, en porcentaje
/// entero. Devuelve `null` si falta algún precio o el anual no ahorra nada.
int? annualSavingsPercent(List<SubscriptionPlan> plans) {
  SubscriptionPlan? find(SubscriptionPlanType type) {
    for (final plan in plans) {
      if (plan.type == type) {
        return plan;
      }
    }
    return null;
  }

  final monthly = find(SubscriptionPlanType.monthly);
  final annual = find(SubscriptionPlanType.annual);
  if (monthly == null ||
      annual == null ||
      monthly.price <= 0 ||
      annual.price <= 0) {
    return null;
  }
  final savings = 1 - annual.price / (monthly.price * 12);
  final percent = (savings * 100).round();
  return percent > 0 ? percent : null;
}
