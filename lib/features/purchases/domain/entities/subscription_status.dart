import 'package:equatable/equatable.dart';

import 'subscription_plan.dart';

/// Estado de la suscripción Premium del usuario. Las compras sueltas de
/// versiones anteriores no cuentan aquí: solo desbloquean moods.
class SubscriptionStatus extends Equatable {
  final bool isActive;

  /// Plan actual, o `null` si no se pudo determinar.
  final SubscriptionPlanType? plan;

  /// Fecha de renovación o de fin si no se renueva.
  final DateTime? expiresAt;

  /// `true` mientras el usuario está dentro de la prueba gratis.
  final bool isInTrial;

  /// `false` si el usuario canceló y la suscripción termina en [expiresAt].
  final bool willRenew;

  /// Página del sistema para gestionar o cancelar la suscripción.
  final String? managementUrl;

  const SubscriptionStatus({
    this.isActive = false,
    this.plan,
    this.expiresAt,
    this.isInTrial = false,
    this.willRenew = true,
    this.managementUrl,
  });

  static const inactive = SubscriptionStatus();

  @override
  List<Object?> get props =>
      [isActive, plan, expiresAt, isInTrial, willRenew, managementUrl];
}
