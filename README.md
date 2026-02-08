Client for the Duplo Train Pusher
=================================

[ESPHome](https://esphome.io/) client for controlling a Lego Duplo train.

Two variants are available:

| Variant | Config file | MCU | Communication | Backend required |
|---------|-------------|-----|---------------|-----------------|
| **HTTP** (original) | `train-pusher-client.yaml` | ESP8266 (D1 Mini) | HTTP REST API | Yes ([train-pusher](https://github.com/vi7/train-pusher)) |
| **BLE** (direct) | `train-pusher-ble.yaml` | ESP32 (D1 Mini 32) | Bluetooth LE | No |

**Table of Contents**

- [Project configuration](#project-configuration)
- [Firmware upload](#firmware-upload)
- [BLE variant](#ble-variant)
- [Hardware](#hardware)
  - [Button to pin mappings](#button-to-pin-mappings)


Project configuration
---------------------

Activate Python virtualenv and install required packages. Check ESPHome docs for Python requirements:
```bash
python3 -m pip install virtualenv
python3 -m virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```

To deactivate Python virtualenv run `deactivate`

> **NOTE:** Python virtualenv MUST be activated with `source venv/bin/activate` each time before using `esphome`

Firmware upload
---------------

> **NOTE:** First time upload should be performed via cable, all subsequent uploads could be performed Over-The-Air (OTA upload)

To build and upload firmware activate Python virtualenv and install packages from the `requirements.txt` as described in the [Project configuration](#project-configuration) section above and then run ESPHome:
```bash
esphome run train-pusher-client.yaml
```

In order to check device logs run:
```bash
esphome logs train-pusher-client.yaml
```

More details on ESPHome usage could be found via `esphome -h` command and on [the official website](https://esphome.io/)

BLE variant
-----------

The BLE variant (`train-pusher-ble.yaml`) uses an ESP32 to communicate directly with the train via Bluetooth Low Energy, eliminating the need for the Node.js backend.

### Requirements

- **D1 Mini 32** (ESP32) -- the ESP8266 does not support BLE
- Same TLC5947 LED driver and button hardware as the HTTP variant

### Discovering the train's BLE MAC address

Turn on the train and scan for BLE devices using one of these methods:

1. **nRF Connect** mobile app (iOS/Android) -- look for a device named `LPF2 Smart Hub`
2. **ESP32 BLE scan** -- flash the config with a placeholder MAC, check the ESPHome logs for discovered devices

### GPIO pin differences from ESP8266

| Button | ESP8266 (D1 Mini) | ESP32 (D1 Mini 32) | Reason |
|--------|:-----------------:|:------------------:|--------|
| Stop   | GPIO 0            | GPIO 25            | GPIO 0 is a strapping pin on ESP32 |
| Brake  | GPIO 2            | GPIO 26            | GPIO 2 drives onboard LED on ESP32 |

All other pins (4, 5, 12, 13, 14, 15, 16) remain the same.

### Configuration

Set the train's BLE MAC address in `train-pusher-ble.yaml` substitutions:

```yaml
substitutions:
  train_mac_address: "AA:BB:CC:DD:EE:FF"
```

### Build and flash

```bash
source venv/bin/activate
esphome run train-pusher-ble.yaml
```

Hardware
--------
### Button to pin mappings

| Button         | TLC5947 pin | D1mini pin   |
|----------------|:-----------:|:------------:|
| Green Backward | 22          | 5            |
| Green Forward  | 23          | 12           |
| White          | 19          | 4            |
| Yellow         | 14          | 5            |
| Blue           | 17          | 2            |
| Red            | 20          | 0            |
