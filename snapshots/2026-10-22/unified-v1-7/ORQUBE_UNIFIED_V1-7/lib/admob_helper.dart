// ORQUBE AdMob helper selector
// Web builds use a safe stub. Android/iOS builds use real Google Mobile Ads.
export 'admob_stub.dart' if (dart.library.io) 'admob_mobile.dart';
