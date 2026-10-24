import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

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
  static const _folderName = 'orqube_safe_hiking_offline';
  static const _legacyImageName = 'saved_hiking_map.png';
  static const _imagePrefix = 'saved_hiking_map_';
  static const _metaName = 'saved_hiking_map.json';

  bool get supported => true;

  Future<Directory> _directory() async {
    final root = await getApplicationSupportDirectory();
    final dir = Directory('${root.path}${Platform.pathSeparator}$_folderName');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<OfflineHikingMapSnapshot?> load() async {
    try {
      final dir = await _directory();
      final meta = File('${dir.path}${Platform.pathSeparator}$_metaName');
      if (!await meta.exists()) return null;

      final decoded = jsonDecode(await meta.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      final imageName = decoded['imageName']?.toString().trim();
      final image = File(
        '${dir.path}${Platform.pathSeparator}'
        '${imageName == null || imageName.isEmpty ? _legacyImageName : imageName}',
      );
      if (!await image.exists()) return null;

      final north = (decoded['north'] as num?)?.toDouble();
      final south = (decoded['south'] as num?)?.toDouble();
      final east = (decoded['east'] as num?)?.toDouble();
      final west = (decoded['west'] as num?)?.toDouble();
      final savedAtRaw = decoded['savedAt']?.toString();
      if (north == null || south == null || east == null || west == null) {
        return null;
      }

      return OfflineHikingMapSnapshot(
        north: north,
        south: south,
        east: east,
        west: west,
        imagePath: image.path,
        savedAt: DateTime.tryParse(savedAtRaw ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<OfflineHikingMapSnapshot?> save({
    required Uint8List pngBytes,
    required double north,
    required double south,
    required double east,
    required double west,
  }) async {
    try {
      final dir = await _directory();
      final meta = File('${dir.path}${Platform.pathSeparator}$_metaName');
      final now = DateTime.now();
      final imageName = '$_imagePrefix${now.millisecondsSinceEpoch}.png';
      final image = File('${dir.path}${Platform.pathSeparator}$imageName');

      await image.writeAsBytes(pngBytes, flush: true);
      await meta.writeAsString(
        jsonEncode({
          'imageName': imageName,
          'north': north,
          'south': south,
          'east': east,
          'west': west,
          'savedAt': now.toIso8601String(),
        }),
        flush: true,
      );

      await for (final entity in dir.list()) {
        if (entity is! File || entity.path == image.path) continue;
        final fileName = entity.uri.pathSegments.isEmpty ? '' : entity.uri.pathSegments.last;
        if ((fileName.startsWith(_imagePrefix) && fileName.endsWith('.png')) ||
            fileName == _legacyImageName) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }

      return OfflineHikingMapSnapshot(
        north: north,
        south: south,
        east: east,
        west: west,
        imagePath: image.path,
        savedAt: now,
      );
    } catch (_) {
      return null;
    }
  }

  ImageProvider<Object>? imageProvider(OfflineHikingMapSnapshot snapshot) {
    final file = File(snapshot.imagePath);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  Future<void> delete() async {
    try {
      final dir = await _directory();
      final meta = File('${dir.path}${Platform.pathSeparator}$_metaName');
      if (await meta.exists()) await meta.delete();
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final fileName = entity.uri.pathSegments.isEmpty ? '' : entity.uri.pathSegments.last;
        if ((fileName.startsWith(_imagePrefix) && fileName.endsWith('.png')) ||
            fileName == _legacyImageName) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
