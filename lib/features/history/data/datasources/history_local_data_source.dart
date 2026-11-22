import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/history_model.dart';

abstract class HistoryLocalDataSource {
  Future<List<HistoryModel>> getCachedHistory();
  Future<void> cacheHistory(List<HistoryModel> history);
  Future<void> addHistoryItem(HistoryModel item);
  Future<void> deleteHistoryItem(String historyId);
  Future<void> clearHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _historyKey = 'wavify_history_cache';
  List<HistoryModel> _inMemoryCache = [];

  HistoryLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<List<HistoryModel>> getCachedHistory() async {
    if (_inMemoryCache.isNotEmpty) {
      return List<HistoryModel>.from(_inMemoryCache);
    }

    try {
      final raw = await secureStorage.read(key: _historyKey);
      if (raw == null || raw.trim().isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _inMemoryCache = decoded
          .map((item) => HistoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return List<HistoryModel>.from(_inMemoryCache);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheHistory(List<HistoryModel> history) async {
    _inMemoryCache = List<HistoryModel>.from(history);
    try {
      final encoded = jsonEncode(history.map((h) => h.toJson()).toList());
      await secureStorage.write(key: _historyKey, value: encoded);
    } catch (_) {}
  }

  @override
  Future<void> addHistoryItem(HistoryModel item) async {
    final list = await getCachedHistory();
    list.removeWhere((h) => h.song.id == item.song.id);
    list.insert(0, item);

    if (list.length > 100) {
      list.removeRange(100, list.length);
    }

    await cacheHistory(list);
  }

  @override
  Future<void> deleteHistoryItem(String historyId) async {
    final list = await getCachedHistory();
    list.removeWhere((h) => h.id == historyId);
    await cacheHistory(list);
  }

  @override
  Future<void> clearHistory() async {
    _inMemoryCache.clear();
    try {
      await secureStorage.delete(key: _historyKey);
    } catch (_) {}
  }
}
