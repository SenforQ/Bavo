import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

class ATTService {
  /// 请求追踪权限
  static Future<bool> requestTrackingPermission() async {
    try {
      // 检查当前权限状态
      final currentStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('Current ATT status: $currentStatus');
      
      // 如果已经授权，直接返回 true
      if (currentStatus == TrackingStatus.authorized) {
        debugPrint('ATT already authorized');
        return true;
      }
      
      // 如果设备不支持，返回 false（但不影响应用运行）
      if (currentStatus == TrackingStatus.notSupported) {
        debugPrint('ATT not supported on this device');
        return false;
      }
      
      // 请求权限 - 添加超时处理
      final status = await AppTrackingTransparency.requestTrackingAuthorization()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('ATT request timeout');
              return TrackingStatus.notDetermined;
            },
          );
      debugPrint('ATT request result: $status');
      
      return status == TrackingStatus.authorized;
    } catch (e, stackTrace) {
      debugPrint('Error requesting ATT permission: $e');
      debugPrint('Stack trace: $stackTrace');
      // 即使出错也返回 false，不影响应用运行
      return false;
    }
  }
  
  /// 获取当前追踪权限状态
  static Future<TrackingStatus> getTrackingStatus() async {
    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      debugPrint('Error getting ATT status: $e');
      return TrackingStatus.notSupported;
    }
  }
  
  /// 检查是否已授权追踪
  static Future<bool> isTrackingAuthorized() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      return status == TrackingStatus.authorized;
    } catch (e) {
      debugPrint('Error checking ATT authorization: $e');
      return false;
    }
  }
}
