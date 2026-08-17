import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/device.dart';

class PhoneRepository {
  static const String _proxyUrl = 'https://tech-comp-app.vercel.app/api/search';
  static List<Device> _memoryCache = [];
  static bool _isInitialized = false;

  static Future<File> get _cacheFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/cached_devices.bin');
  }

  static Future<void> init() async {
    if (_isInitialized) return;

    final List<Device> allDevices = [];

    // 1. Read your existing regular JSON asset files
    final assetPaths = [
      'assets/data/phones_part1.json',
      'assets/data/phones_part2.json',
    ];

    for (final String path in assetPaths) {
      try {
        final String rawJson = await rootBundle.loadString(path);
        final List<dynamic> jsonList = json.decode(rawJson) as List<dynamic>;

        allDevices.addAll(
          jsonList.map((e) => Device.fromJson(e as Map<String, dynamic>)),
        );
      } catch (e) {
        debugPrint('JSON asset load error ($path): $e');
      }
    }

    // 2. Read low-storage GZip binary disk cache (proxy downloads)
    try {
      final file = await _cacheFile;
      if (await file.exists()) {
        final List<int> compressedBytes = await file.readAsBytes();
        final String rawJson = utf8.decode(gzip.decode(compressedBytes));
        final List<dynamic> cachedList = json.decode(rawJson) as List<dynamic>;

        for (final item in cachedList) {
          final device = Device.fromJson(item as Map<String, dynamic>);
          allDevices.removeWhere(
            (d) => d.name.toLowerCase() == device.name.toLowerCase(),
          );
          allDevices.add(device);
        }
      }
    } catch (e) {
      debugPrint('Disk binary cache read error: $e');
    }

    _memoryCache = allDevices;
    _isInitialized = true;
  }

  static List<Device> searchLocal(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return _memoryCache.where((d) {
      return d.name.toLowerCase().contains(q) ||
             d.brand.toLowerCase().contains(q) ||
             d.processor.toLowerCase().contains(q);
    }).toList();
  }

  static Future<Device?> fetchFromProxyAndCache(String query) async {
    try {
      final uri = Uri.parse('$_proxyUrl?q=${Uri.encodeComponent(query)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final newDevice = Device.fromJson(data);

        _memoryCache.removeWhere(
          (d) => d.name.toLowerCase() == newDevice.name.toLowerCase(),
        );
        _memoryCache.add(newDevice);

        // Compress and write to disk in GZip binary format
        await _saveBinaryDiskCache();

        return newDevice;
      }
    } catch (e) {
      debugPrint('Proxy fetch error: $e');
    }
    return null;
  }

  static Future<List<Device>> search(String query) async {
    // 1. Ensure local data is initialized
    await init();

    // 2. Search local JSON database first
    final localResults = searchLocal(query);
    if (localResults.isNotEmpty) {
      return localResults;
    }

    // 3. Fallback to proxy fetch & cache if not found locally
    final device = await fetchFromProxyAndCache(query);
    return device != null ? [device] : [];
  }

  static Future<void> _saveBinaryDiskCache() async {
    try {
      final file = await _cacheFile;
      final String rawJson = json.encode(
        _memoryCache.map((d) => d.toJson()).toList(),
      );

      final List<int> compressedBytes = gzip.encode(utf8.encode(rawJson));
      await file.writeAsBytes(compressedBytes, flush: true);
    } catch (e) {
      debugPrint('Disk binary cache write error: $e');
    }
  }
}