/// ORQUBE Google AdSense web configuration.
///
/// Keep placeholders until Google AdSense approves the site and issues the
/// real publisher/ad-unit values. Never commit another publisher's IDs.
class AdSenseConfig {
  const AdSenseConfig._();

  /// Replace with your own value, for example: ca-pub-1234567890123456
  static const String publisherId = 'ca-pub-REPLACE_WITH_YOUR_PUBLISHER_ID';

  /// Responsive ad unit used on the public web home page.
  static const String homeResponsiveSlot = 'REPLACE_WITH_HOME_AD_SLOT_ID';

  /// Responsive ad unit used in the mining dashboard.
  static const String miningResponsiveSlot = 'REPLACE_WITH_MINING_AD_SLOT_ID';

  /// Keep true during development. In this mode no Google ad request is sent;
  /// a compact neutral placeholder is rendered instead.
  static const bool developmentPlaceholderMode = true;

  static bool get hasValidPublisherId =>
      RegExp(r'^ca-pub-\d{16}$').hasMatch(publisherId);

  static bool isValidSlot(String value) => RegExp(r'^\d+$').hasMatch(value);
}
