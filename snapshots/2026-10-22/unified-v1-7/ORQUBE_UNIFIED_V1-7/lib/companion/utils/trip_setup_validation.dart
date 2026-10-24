bool tripStepReady({required int step, required bool understood, required bool privacy,
  required bool locationConsent, required bool hasPosition, required bool hiking,
  required bool hasDestination, required bool routeOnly, required bool futureReturn,
  required bool share, required bool hasRecipients}) => switch(step) {
    0 => understood,
    1 => privacy && locationConsent,
    2 => hasPosition,
    3 => (hasDestination || (hiking && routeOnly)) && (!hiking || futureReturn),
    4 => !share || hasRecipients,
    _ => true,
  };
