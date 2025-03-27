import 'package:flutter/foundation.dart';

class ItemState extends ChangeNotifier {
  // 基础数据
  int _waterCount = 0;
  int _fertilizerCount = 0;
  int _leafyHeartsCount = 0;
  int _plantStage = 1; // 1: 幼苗, 2: 成长, 3: 成熟
  int _waterUsed = 0;
  int _fertilizerUsed = 0;
  DateTime _lastGrowthUpdate = DateTime.now();
  final Map<DateTime, Map<String, dynamic>> _moodLog = {};
  String _currentEmotion = "Happy";

  // Getters
  int get waterCount => _waterCount;
  int get fertilizerCount => _fertilizerCount;
  int get leafyHeartsCount => _leafyHeartsCount;
  int get plantGrowthStage => _plantStage;
  DateTime get lastGrowthUpdate => _lastGrowthUpdate;
  Map<DateTime, Map<String, dynamic>> get moodLog => _moodLog;
  String get currentEmotion => _currentEmotion;
  int get waterUsed => _waterUsed;
  int get fertilizerUsed => _fertilizerUsed;

  // 物品相关方法
  void useWater() {
    if (_waterCount > 0) {
      _waterCount--;
      _waterUsed++;
      
      // 检查是否需要生长到第二阶段
      if (_plantStage == 1 && (_waterUsed >= 2 || _fertilizerUsed >= 1)) {
        _plantStage = 2;
      }
      
      notifyListeners();
    }
  }

  void useFertilizer() {
    if (_fertilizerCount > 0) {
      _fertilizerCount--;
      _fertilizerUsed++;
      
      // 检查是否需要生长到第二阶段
      if (_plantStage == 1 && (_waterUsed >= 2 || _fertilizerUsed >= 1)) {
        _plantStage = 2;
      }
      
      notifyListeners();
    }
  }

  void purchaseWater() {
    _waterCount++;
    notifyListeners();
  }

  void purchaseFertilizer() {
    _fertilizerCount++;
    notifyListeners();
  }

  // 心形叶子相关方法
  void updateLeafyHearts(int count) {
    _leafyHeartsCount = count;
    notifyListeners();
  }

  void addLeafyHeart() {
    _leafyHeartsCount++;
    notifyListeners();
  }

  void useLeafyHearts(int amount) {
    if (_leafyHeartsCount >= amount) {
      _leafyHeartsCount -= amount;
      notifyListeners();
    }
  }

  // 植物生长相关方法
  void updatePlantGrowth() {
    DateTime now = DateTime.now();
    int daysSinceLastGrowth = now.difference(_lastGrowthUpdate).inDays;
    
    if (daysSinceLastGrowth >= 3 && _plantStage < 2) {
      _plantStage++;
      _lastGrowthUpdate = now;
      notifyListeners();
    }
  }

  // 心情相关方法
  void recordMood(String mood, String note) {
    final now = DateTime.now();
    _moodLog[now] = {
      'mood': mood,
      'note': note,
    };
    _currentEmotion = mood;
    notifyListeners();
  }

  void deleteMood(DateTime date) {
    _moodLog.remove(date);
    notifyListeners();
  }

  // 检查每日记录限制
  bool canRecordMoodToday() {
    final today = DateTime.now();
    final todayRecords = _moodLog.entries.where((entry) {
      return entry.key.year == today.year &&
             entry.key.month == today.month &&
             entry.key.day == today.day;
    }).length;
    
    return todayRecords <= 3;
  }
} 