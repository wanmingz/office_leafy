import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class MoodEntry {
  final DateTime date;
  final Map<String, dynamic> value;

  MoodEntry({
    required this.date,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      value: json['value'],
    );
  }
}

class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  static const String _storageKey = 'mood_entries';

  MoodNotifier() : super([]) {
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final moodData = prefs.getString(_storageKey);
    if (moodData != null) {
      final List<dynamic> decoded = json.decode(moodData);
      state = decoded.map((item) => MoodEntry.fromJson(item)).toList();
    }
  }

  Future<void> _saveMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(state.map((entry) => entry.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addMood(MoodEntry entry) {
    state = [...state, entry];
    _saveMoods();
  }

  void clearMoods() {
    state = [];
    _saveMoods();
  }
}

final moodProvider = StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  return MoodNotifier();
});

Color getMoodColor(String mood) {
  switch (mood) {
    case 'Happy': return Colors.amber;
    case 'Excited': return Colors.orange;
    case 'Grateful': return Colors.red;
    case 'Okay': return Colors.green;
    case 'Sad': return Colors.blue;
    case 'Stressed': return Colors.purple;
    case 'Tired': return Colors.indigo;
    case 'Annoyed': return Colors.deepOrange;
    default: return Colors.grey;
  }
} 