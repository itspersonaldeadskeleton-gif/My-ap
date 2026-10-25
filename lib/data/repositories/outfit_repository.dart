import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/outfit.dart';
import '../models/outfit_plan.dart';
import '../models/wear_history.dart';
import '../models/weather_snapshot.dart';
import 'local_store.dart';

class OutfitRepository {
  OutfitRepository(this._store);
  final LocalStore _store;
  final _uuid = const Uuid();

  Future<void> init() => _store.init();

  Future<List<Outfit>> getOutfits() async {
    final raw = await _store.readString(StoreKeys.outfits);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => Outfit.fromJson(e)).toList();
  }

  Future<Outfit> addOutfit(Outfit outfit) async {
    final outfits = await getOutfits();
    final newOutfit = outfit.copyWith(
      id: outfit.id.isNotEmpty ? outfit.id : _uuid.v4(),
      createdAt: DateTime.now(),
    );
    outfits.add(newOutfit);
    await _persistOutfits(outfits);
    return newOutfit;
  }

  Future<Outfit> updateOutfit(Outfit outfit) async {
    final outfits = await getOutfits();
    final index = outfits.indexWhere((e) => e.id == outfit.id);
    if (index == -1) throw StateError('Outfit not found: ${outfit.id}');
    outfits[index] = outfit;
    await _persistOutfits(outfits);
    return outfits[index];
  }

  Future<void> deleteOutfit(String id) async {
    final outfits = await getOutfits()..removeWhere((e) => e.id == id);
    await _persistOutfits(outfits);
  }

  Future<Outfit> markWorn(String id, {DateTime? when, double? rating, String? occasion}) async {
    final outfits = await getOutfits();
    final index = outfits.indexWhere((e) => e.id == id);
    if (index == -1) throw StateError('Outfit not found: $id');
    final now = when ?? DateTime.now();
    outfits[index] = outfits[index].copyWith(lastWornAt: now);
    await _persistOutfits(outfits);
    await addWearHistory(WearHistory(
      id: _uuid.v4(),
      outfitId: id,
      date: now,
      occasion: occasion,
      rating: rating,
    ));
    return outfits[index];
  }

  Future<List<OutfitPlan>> getPlans() async {
    final raw = await _store.readString(StoreKeys.outfitPlans);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => OutfitPlan.fromJson(e)).toList();
  }

  Future<OutfitPlan> addPlan(OutfitPlan plan) async {
    final plans = await getPlans();
    final newPlan = plan.copyWith(id: plan.id.isNotEmpty ? plan.id : _uuid.v4());
    plans.add(newPlan);
    await _persistPlans(plans);
    return newPlan;
  }

  Future<void> updatePlan(OutfitPlan plan) async {
    final plans = await getPlans();
    final index = plans.indexWhere((e) => e.id == plan.id);
    if (index == -1) throw StateError('Outfit plan not found: ${plan.id}');
    plans[index] = plan;
    await _persistPlans(plans);
  }

  Future<void> deletePlan(String id) async {
    final plans = await getPlans()..removeWhere((e) => e.id == id);
    await _persistPlans(plans);
  }

  Future<List<WearHistory>> getWearHistory() async {
    final raw = await _store.readString(StoreKeys.wearHistory);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => WearHistory.fromJson(e)).toList();
  }

  Future<WearHistory> addWearHistory(WearHistory history) async {
    final list = await getWearHistory();
    list.add(history);
    await _store.writeString(
      StoreKeys.wearHistory,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    return history;
  }

  Future<List<WeatherSnapshot>> getWeatherSnapshots() async {
    final raw = await _store.readString(StoreKeys.weatherSnapshots);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => WeatherSnapshot.fromJson(e)).toList();
  }

  Future<WeatherSnapshot> saveWeather(WeatherSnapshot snapshot) async {
    final list = await getWeatherSnapshots();
    list.add(snapshot);
    await _store.writeString(
      StoreKeys.weatherSnapshots,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    return snapshot;
  }

  Future<void> _persistOutfits(List<Outfit> outfits) async {
    await _store.writeString(
      StoreKeys.outfits,
      jsonEncode(outfits.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistPlans(List<OutfitPlan> plans) async {
    await _store.writeString(
      StoreKeys.outfitPlans,
      jsonEncode(plans.map((e) => e.toJson()).toList()),
    );
  }
}
