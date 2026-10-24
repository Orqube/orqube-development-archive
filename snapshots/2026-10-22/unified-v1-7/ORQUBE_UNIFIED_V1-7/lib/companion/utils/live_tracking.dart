import 'package:latlong2/latlong.dart';
enum TrackingFreshness { fresh, delayed, expired, cached, stopped }
TrackingFreshness trackingFreshness({required bool active, required DateTime now,
  required DateTime? updatedAt, required DateTime? expiresAt, required bool cached}) {
  if (!active) return TrackingFreshness.stopped;
  if (expiresAt == null || !now.isBefore(expiresAt)) return TrackingFreshness.expired;
  if (cached) return TrackingFreshness.cached;
  if (updatedAt == null || now.difference(updatedAt) > const Duration(seconds: 20)) return TrackingFreshness.delayed;
  return TrackingFreshness.fresh;
}
// Interpolate between received fixes only. Never predict beyond the newest fix.
LatLng interpolateFix(LatLng from, LatLng to, double fraction) {
  final t = fraction.clamp(0.0, 1.0);
  final delta = ((to.longitude - from.longitude + 540) % 360) - 180;
  final longitude = ((from.longitude + delta * t + 540) % 360) - 180;
  return LatLng(from.latitude + (to.latitude - from.latitude) * t, longitude);
}
