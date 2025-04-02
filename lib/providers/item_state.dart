import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  // 构造函数
  ItemState() {
    _loadData();
  }

  // 加载保存的数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _waterCount = prefs.getInt('waterCount') ?? 0;
    _fertilizerCount = prefs.getInt('fertilizerCount') ?? 0;
    _leafyHeartsCount = prefs.getInt('leafyHeartsCount') ?? 0;
    _plantStage = prefs.getInt('plantStage') ?? 1;
    _waterUsed = prefs.getInt('waterUsed') ?? 0;
    _fertilizerUsed = prefs.getInt('fertilizerUsed') ?? 0;
    _lastGrowthUpdate = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt('lastGrowthUpdate') ?? DateTime.now().millisecondsSinceEpoch
    );
    _currentEmotion = prefs.getString('currentEmotion') ?? "Happy";

    // 加载心情日志
    String? moodLogJson = prefs.getString('moodLog');
    if (moodLogJson != null) {
      Map<String, dynamic> decodedLog = json.decode(moodLogJson);
      _moodLog.clear();
      decodedLog.forEach((key, value) {
        _moodLog[DateTime.parse(key)] = Map<String, dynamic>.from(value);
      });
    }

    notifyListeners();
  }

  // 保存数据
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('waterCount', _waterCount);
    await prefs.setInt('fertilizerCount', _fertilizerCount);
    await prefs.setInt('leafyHeartsCount', _leafyHeartsCount);
    await prefs.setInt('plantStage', _plantStage);
    await prefs.setInt('waterUsed', _waterUsed);
    await prefs.setInt('fertilizerUsed', _fertilizerUsed);
    await prefs.setInt('lastGrowthUpdate', _lastGrowthUpdate.millisecondsSinceEpoch);
    await prefs.setString('currentEmotion', _currentEmotion);

    // 保存心情日志
    Map<String, dynamic> encodedLog = {};
    _moodLog.forEach((key, value) {
      encodedLog[key.toIso8601String()] = value;
    });
    await prefs.setString('moodLog', json.encode(encodedLog));
  }

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
      
      _saveData();
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
      
      _saveData();
      notifyListeners();
    }
  }

  void purchaseWater() {
    _waterCount++;
    _saveData();
    notifyListeners();
  }

  void purchaseFertilizer() {
    _fertilizerCount++;
    _saveData();
    notifyListeners();
  }

  // 心形叶子相关方法
  void updateLeafyHearts(int count) {
    _leafyHeartsCount = count;
    _saveData();
    notifyListeners();
  }

  void addLeafyHeart() {
    _leafyHeartsCount++;
    _saveData();
    notifyListeners();
  }

  void useLeafyHearts(int amount) {
    if (_leafyHeartsCount >= amount) {
      _leafyHeartsCount -= amount;
      _saveData();
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
      _saveData();
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
    _saveData();
    notifyListeners();
  }

  void deleteMood(DateTime date) {
    _moodLog.remove(date);
    _saveData();
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

  // 重置所有数据
  Future<void> resetAllData() async {
    _waterCount = 0;
    _fertilizerCount = 0;
    _leafyHeartsCount = 0;
    _plantStage = 1;
    _waterUsed = 0;
    _fertilizerUsed = 0;
    _lastGrowthUpdate = DateTime.now();
    _moodLog.clear();
    _currentEmotion = "Happy";

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 清除所有存储的数据
    
    notifyListeners();
  }
} 