import 'package:flutter_riverpod/flutter_riverpod.dart';

class IoTDeviceItem {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final bool isConnected;
  final int batteryPct;
  final DateTime lastSync;

  const IoTDeviceItem({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.isConnected,
    required this.batteryPct,
    required this.lastSync,
  });
}

class IoTState {
  final List<IoTDeviceItem> devices;
  final String? activeReminder;
  final bool isPairing;

  const IoTState({
    this.devices = const [],
    this.activeReminder,
    this.isPairing = false,
  });

  IoTState copyWith({
    List<IoTDeviceItem>? devices,
    String? activeReminder,
    bool? isPairing,
  }) {
    return IoTState(
      devices: devices ?? this.devices,
      activeReminder: activeReminder,
      isPairing: isPairing ?? this.isPairing,
    );
  }
}

class IoTNotifier extends StateNotifier<IoTState> {
  IoTNotifier()
      : super(IoTState(
          devices: [
            IoTDeviceItem(
              deviceId: 'NC-WATCH-7X',
              deviceName: 'NutriCare Pulse Watch',
              deviceType: 'smartwatch',
              isConnected: true,
              batteryPct: 88,
              lastSync: DateTime.now(),
            )
          ],
          activeReminder: '💧 Minum yuk! Asupan air Anda masih 600 ml di bawah target harian.',
        ));

  Future<void> pairNewDevice(String name, String type) async {
    state = state.copyWith(isPairing: true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final newDev = IoTDeviceItem(
      deviceId: 'NC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      deviceName: name,
      deviceType: type,
      isConnected: true,
      batteryPct: 100,
      lastSync: DateTime.now(),
    );

    state = state.copyWith(
      isPairing: false,
      devices: [...state.devices, newDev],
      activeReminder: 'Perangkat baru terhubung! Sistem siap mengirimkan pengingat gizi real-time.',
    );
  }

  void dismissReminder() {
    state = state.copyWith(activeReminder: null);
  }
}

final iotProvider = StateNotifierProvider<IoTNotifier, IoTState>((ref) {
  return IoTNotifier();
});
