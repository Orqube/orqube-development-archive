class LaunchEconomyPolicy {
  const LaunchEconomyPolicy._();

  static const int signupPoints = 1000;
  static const double starterOrbs = 10.0;
  static const double miningOrbsPerHour = 0.2;
  static const double miningDailyMaxOrbs = miningOrbsPerHour * 24;

  static const double aiPlanningFeeOrbs = 0.0;
  static const double aiLogoThreePackFeeOrbs = 0.0;
  static const double publicTokenCreateFeeOrbs = 50.0;
  static const double kairosDeployFeeOrbs = 3.0;
  static const double aiMarketingBasicFeeOrbs = 100.0;

  static const double fullLaunchFeeOrbs =
      aiLogoThreePackFeeOrbs +
      publicTokenCreateFeeOrbs +
      kairosDeployFeeOrbs +
      aiMarketingBasicFeeOrbs;

  static const int defaultTokenSupply = 1000000;
  static const int minTokenSupply = 1;
  static const int maxTokenSupply = 1000000000000;
}
