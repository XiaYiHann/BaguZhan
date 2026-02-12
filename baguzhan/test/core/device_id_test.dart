import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baguzhan/core/device_id.dart';

void main() {
  group('DeviceId', () {
    tearDown(() async {
      // 清理测试数据
      SharedPreferences.setMockInitialValues({});
      await DeviceId.reset();
    });

    group('首次启动生成设备 ID', () {
      test('应该生成 UUID v4 格式的设备 ID', () async {
        SharedPreferences.setMockInitialValues({});

        final deviceId = await DeviceId.get();

        // 验证 UUID 格式: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        expect(deviceId, matches(RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          caseSensitive: false,
        )));
      });

      test('应该将设备 ID 持久化到本地存储', () async {
        SharedPreferences.setMockInitialValues({});

        final deviceId1 = await DeviceId.get();
        final prefs = await SharedPreferences.getInstance();
        final storedId = prefs.getString('device_id');

        expect(storedId, isNotNull);
        expect(storedId, deviceId1);
      });
    });

    group('后续启动使用已有设备 ID', () {
      test('应该使用已存储的设备 ID', () async {
        const existingDeviceId = '550e8400-e29b-41d4-a716-446655440000';
        SharedPreferences.setMockInitialValues({
          'device_id': existingDeviceId,
        });

        final deviceId = await DeviceId.get();

        expect(deviceId, equals(existingDeviceId));
      });

      test('多次调用应该返回相同的设备 ID', () async {
        SharedPreferences.setMockInitialValues({});

        final deviceId1 = await DeviceId.get();
        final deviceId2 = await DeviceId.get();

        expect(deviceId2, equals(deviceId1));
      });
    });

    group('设备 ID 格式验证', () {
      test('有效的 UUID 应该通过验证', () {
        const validUuids = [
          '550e8400-e29b-41d4-a716-446655440000',
          '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
          '6ba7b811-9dad-11d1-80b4-00c04fd430c8',
        ];

        for (final uuid in validUuids) {
          expect(DeviceId.isValid(uuid), isTrue, reason: '$uuid should be valid');
        }
      });

      test('无效的 UUID 应该验证失败', () {
        const invalidUuids = [
          '',
          'not-a-uuid',
          '550e8400-e29b-41d4-a716', // 太短
          '550e8400-e29b-41d4-a716-446655440000-extra', // 太长
          'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', // 无效字符
        ];

        for (final uuid in invalidUuids) {
          expect(DeviceId.isValid(uuid), isFalse, reason: '$uuid should be invalid');
        }
      });
    });

    group('reset', () {
      test('应该清除设备 ID', () async {
        SharedPreferences.setMockInitialValues({});

        final deviceId1 = await DeviceId.get();
        await DeviceId.reset();

        // 重置后获取新的设备 ID
        final deviceId2 = await DeviceId.get();

        // 设备 ID 应该不同（因为生成了新的 UUID）
        expect(deviceId2, isNot(equals(deviceId1)));
      });
    });
  });
}
