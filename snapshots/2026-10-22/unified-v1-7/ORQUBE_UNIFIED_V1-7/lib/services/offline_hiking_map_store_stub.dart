import 'dart:typed_data';

import 'package:flutter/widgets.dart';

class OfflineHikingMapSnapshot {
  final double north;
  final double south;
  final double east;
  final double west;
  final String imagePath;
  final DateTime savedAt;

  const OfflineHikingMapSnapshot({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.imagePath,
    required this.savedAt,
  });
}

class OfflineHikingMapStore {
  bool get supported => false;

  Future<OfflineHikingMapSnapshot?> load() async => null;

  Future<OfflineHikingMapSnapshot?> save({
    required Uint8List pngBytes,
    required double north,
    required double south,
    required double east,
    required double west,
  }) async => null;

  ImageProvider<Object>? imageProvider(OfflineHikingMapSnapshot snapshot) => null;

  Future<void> delete() async {}
}
