import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Device ID 服务
/// 负责生成和持久化设备唯一标识符
class DeviceId {
  DeviceId._();

  static const String _storageKey = 'device_id';
  static final Uuid _uuid = const Uuid();
  static String? _cachedDeviceId;

  /// 获取设备 ID
  /// 如果本地不存在，则生成新的 UUID v4 并持久化
  static Future<String> get() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString(_storageKey);

    if (storedId != null && storedId.isNotEmpty) {
      _cachedDeviceId = storedId;
      return storedId;
    }

    // 生成新的设备 ID
    final newId = _uuid.v4();
    await prefs.setString(_storageKey, newId);
    _cachedDeviceId = newId;

    return newId;
  }

  /// 重置设备 ID（用于测试或清除数据）
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _cachedDeviceId = null;
  }

  /// 检查设备 ID 是否有效（UUID 格式验证）
  static bool isValid(String deviceId) {
    // UUID v4 格式: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    // 版本位在第3组，第1个字符必须是4
    // 变体位在第4组，第1个字符必须是8、9、a或b
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(deviceId);
  }
}
