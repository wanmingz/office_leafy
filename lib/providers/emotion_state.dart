import 'package:flutter/foundation.dart';

class Emotion {
  final DateTime date;
  final int value;
  final String note;

  Emotion({
    required this.date,
    required this.value,
    this.note = '',
  });
}

class EmotionState with ChangeNotifier {
  final List<Emotion> _emotions = [];

  List<Emotion> get emotions => _emotions;

  void addEmotion(Emotion emotion) {
    _emotions.add(emotion);
    notifyListeners();
  }

  void removeEmotion(DateTime date) {
    _emotions.removeWhere((emotion) => 
      emotion.date.year == date.year &&
      emotion.date.month == date.month &&
      emotion.date.day == date.day
    );
    notifyListeners();
  }

  void updateEmotion(DateTime date, Emotion newEmotion) {
    final index = _emotions.indexWhere((emotion) => 
      emotion.date.year == date.year &&
      emotion.date.month == date.month &&
      emotion.date.day == date.day
    );
    if (index != -1) {
      _emotions[index] = newEmotion;
      notifyListeners();
    }
  }

  Emotion? getEmotionForDate(DateTime date) {
    return _emotions.firstWhere(
      (emotion) => 
        emotion.date.year == date.year &&
        emotion.date.month == date.month &&
        emotion.date.day == date.day,
      orElse: () => Emotion(date: date, value: 0),
    );
  }
} 