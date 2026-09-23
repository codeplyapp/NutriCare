from abc import ABC, abstractmethod
from typing import Dict, Any

class DeviceAdapter(ABC):
    """
    Interface Adapter untuk perangkat IoT (jam tangan pintar multi-brand).
    Memisahkan protokol komunikasi hardware dari logika evaluasi gizi inti.
    """
    @abstractmethod
    def format_payload_for_device(self, reminder_title: str, reminder_message: str, urgency: str) -> Dict[str, Any]:
        pass

    @abstractmethod
    def parse_incoming_telemetry(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        pass

class AppleWatchAdapter(DeviceAdapter):
    def format_payload_for_device(self, reminder_title: str, reminder_message: str, urgency: str) -> Dict[str, Any]:
        return {
            "aps": {
                "alert": {
                    "title": reminder_title,
                    "body": reminder_message
                },
                "sound": "default",
                "category": "NUTRICARE_REMINDER"
            },
            "haptic": "notification" if urgency == "normal" else "warning",
            "complication_update": True
        }

    def parse_incoming_telemetry(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "battery": raw_data.get("battery_pct", 100),
            "source": "apple_healthkit"
        }

class WearOSAdapter(DeviceAdapter):
    def format_payload_for_device(self, reminder_title: str, reminder_message: str, urgency: str) -> Dict[str, Any]:
        return {
            "notification": {
                "title": reminder_title,
                "text": reminder_message,
                "channel_id": "nutricare_smart_reminders",
                "vibrate_pattern": [0, 250, 200, 250] if urgency == "urgent" else [0, 150, 100]
            },
            "tile_refresh": True
        }

    def parse_incoming_telemetry(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "battery": raw_data.get("battery_pct", 100),
            "source": "google_health_connect"
        }

class GenericMQTTAdapter(DeviceAdapter):
    def format_payload_for_device(self, reminder_title: str, reminder_message: str, urgency: str) -> Dict[str, Any]:
        return {
            "topic_suffix": "/alerts",
            "t": reminder_title,
            "m": reminder_message,
            "vib": 1 if urgency == "normal" else 2
        }

    def parse_incoming_telemetry(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "battery": raw_data.get("battery_pct", 100),
            "source": "mqtt_raw"
        }

def get_device_adapter(device_type: str) -> DeviceAdapter:
    dt = device_type.lower()
    if "apple" in dt or "watchos" in dt:
        return AppleWatchAdapter()
    elif "wear" in dt or "android" in dt or "samsung" in dt:
        return WearOSAdapter()
    return GenericMQTTAdapter()
