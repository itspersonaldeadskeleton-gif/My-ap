import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/styling_session.dart';
import '../models/weather_snapshot.dart';
import 'local_store.dart';

class StylingRepository {
  StylingRepository(this._store);
  final LocalStore _store;
  final _uuid = const Uuid();

  Future<void> init() => _store.init();

  Future<List<StylingSession>> getSessions() async {
    final raw = await _store.readString(StoreKeys.stylingSessions);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => StylingSession.fromJson(e)).toList();
  }

  Future<StylingSession> startSession(String userId) async {
    final session = StylingSession(
      id: _uuid.v4(),
      userId: userId,
      startedAt: DateTime.now(),
    );
    final sessions = await getSessions()..add(session);
    await _persistSessions(sessions);
    return session;
  }

  Future<void> endSession(String id, {int? recommendationsCount, int? savedCount}) async {
    final sessions = await getSessions();
    final index = sessions.indexWhere((e) => e.id == id);
    if (index == -1) return;
    sessions[index] = sessions[index].copyWith(
      endedAt: DateTime.now(),
      recommendationsCount: recommendationsCount ?? sessions[index].recommendationsCount,
      savedCount: savedCount ?? sessions[index].savedCount,
      status: 'completed',
    );
    await _persistSessions(sessions);
  }

  Future<List<SavedRecommendation>> getSavedRecommendations() async {
    final raw = await _store.readString(StoreKeys.savedRecommendations);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => SavedRecommendation.fromJson(e)).toList();
  }

  Future<SavedRecommendation> saveRecommendation(SavedRecommendation rec) async {
    final list = await getSavedRecommendations();
    final newRec = rec.copyWith(
      id: rec.id.isNotEmpty ? rec.id : _uuid.v4(),
      createdAt: DateTime.now(),
    );
    list.add(newRec);
    await _persistRecommendations(list);
    return newRec;
  }

  Future<void> deleteRecommendation(String id) async {
    final list = await getSavedRecommendations()..removeWhere((e) => e.id == id);
    await _persistRecommendations(list);
  }

  Future<void> _persistSessions(List<StylingSession> sessions) async {
    await _store.writeString(
      StoreKeys.stylingSessions,
      jsonEncode(sessions.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistRecommendations(List<SavedRecommendation> recs) async {
    await _store.writeString(
      StoreKeys.savedRecommendations,
      jsonEncode(recs.map((e) => e.toJson()).toList()),
    );
  }
}
