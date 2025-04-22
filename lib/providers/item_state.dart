import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ItemState extends ChangeNotifier {
  // 基础数据
  int _growthStage = 0;
  int _waterCount = 0;
  int _fertilizerCount = 0;
  int _leafyHeartsCount = 0;
  DateTime? _lastGrowthUpdate;
  final Map<DateTime, Map<String, dynamic>> _moodLog = {};
  String _currentEmotion = "Happy";
  
  // 添加计数器
  int _usedWaterCount = 0;
  int _usedFertilizerCount = 0;

  // 构造函数
  ItemState() {
    _initializeData();
  }

  // 初始化数据
  Future<void> _initializeData() async {
    try {
      await _loadData();
    } catch (e) {
      print('Error loading data: $e');
      // 如果加载失败，使用默认值
      _saveData();
    }
  }

  // 加载保存的数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _waterCount = prefs.getInt('waterCount') ?? 0;
    _fertilizerCount = prefs.getInt('fertilizerCount') ?? 0;
    _leafyHeartsCount = prefs.getInt('leafyHeartsCount') ?? 0;
    _growthStage = prefs.getInt('growthStage') ?? 0;
    _usedWaterCount = prefs.getInt('usedWaterCount') ?? 0;
    _usedFertilizerCount = prefs.getInt('usedFertilizerCount') ?? 0;
    _lastGrowthUpdate = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt('lastGrowthUpdate') ?? DateTime.now().millisecondsSinceEpoch
    );
    _currentEmotion = prefs.getString('currentEmotion') ?? "Happy";

    // 加载心情日志
    String? moodLogJson = prefs.getString('moodLog');
    if (moodLogJson != null) {
      try {
        Map<String, dynamic> decodedLog = json.decode(moodLogJson);
        _moodLog.clear();
        decodedLog.forEach((key, value) {
          _moodLog[DateTime.parse(key)] = Map<String, dynamic>.from(value);
        });
      } catch (e) {
        print('Error decoding mood log: $e');
        _moodLog.clear();
      }
    }

    notifyListeners();
  }

  // 保存数据
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('waterCount', _waterCount);
    await prefs.setInt('fertilizerCount', _fertilizerCount);
    await prefs.setInt('leafyHeartsCount', _leafyHeartsCount);
    await prefs.setInt('growthStage', _growthStage);
    await prefs.setInt('usedWaterCount', _usedWaterCount);
    await prefs.setInt('usedFertilizerCount', _usedFertilizerCount);
    await prefs.setInt('lastGrowthUpdate', _lastGrowthUpdate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch);
    await prefs.setString('currentEmotion', _currentEmotion);

    // 保存心情日志
    Map<String, dynamic> encodedLog = {};
    _moodLog.forEach((key, value) {
      encodedLog[key.toIso8601String()] = value;
    });
    await prefs.setString('moodLog', json.encode(encodedLog));
  }

  // Getters
  int get growthStage => _growthStage;
  int get waterCount => _waterCount;
  int get fertilizerCount => _fertilizerCount;
  int get leafyHeartsCount => _leafyHeartsCount;
  DateTime? get lastGrowthUpdate => _lastGrowthUpdate;
  Map<DateTime, Map<String, dynamic>> get moodLog => _moodLog;
  String get currentEmotion => _currentEmotion;
  int get usedWaterCount => _usedWaterCount;
  int get usedFertilizerCount => _usedFertilizerCount;

  // 物品相关方法
  void useWater() {
    if (_waterCount > 0) {
      _waterCount--;
      _usedWaterCount++;
      print('Using water: current count $_usedWaterCount, current stage $_growthStage');
      _checkGrowth();
      _saveData();
      notifyListeners();
    }
  }

  void useFertilizer() {
    if (_fertilizerCount > 0) {
      _fertilizerCount--;
      _usedFertilizerCount++;
      print('Using fertilizer: current count $_usedFertilizerCount, current stage $_growthStage');
      _checkGrowth();
      _saveData();
      notifyListeners();
    }
  }

  void _checkGrowth() {
    print('Checking growth: stage $_growthStage, water used $_usedWaterCount, fertilizer used $_usedFertilizerCount');
    if (_growthStage == 0 && _usedWaterCount >= 1 && _usedFertilizerCount >= 1) {
      _growthStage = 1;
      _usedWaterCount = 0;
      _usedFertilizerCount = 0;
      print('Growing to stage 1');
      notifyListeners();
    } else if (_growthStage == 1 && _usedWaterCount >= 3 && _usedFertilizerCount >= 1) {
      _growthStage = 2;
      _usedWaterCount = 0;
      _usedFertilizerCount = 0;
      print('Growing to stage 2');
      notifyListeners();
    } else if (_growthStage == 2 && (_usedWaterCount >= 5 || _usedFertilizerCount >= 3)) {
      _growthStage = 3;
      _usedWaterCount = 0;
      _usedFertilizerCount = 0;
      print('Growing to stage 3');
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
    // 移除时间触发生长的逻辑
    // 现在只通过使用水和肥料来触发生长
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

  // 重置所有数据
  void resetAllData() {
    _waterCount = 0;
    _fertilizerCount = 0;
    _leafyHeartsCount = 0;
    _growthStage = 0;
    _usedWaterCount = 0;
    _usedFertilizerCount = 0;
    _lastGrowthUpdate = null;
    _moodLog.clear();
    _currentEmotion = "Happy";
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
} 