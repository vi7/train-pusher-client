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

Install [uv](https://docs.astral.sh/uv/getting-started/installation/) once. On macOS with Homebrew:

```bash
brew install uv
```

On Linux, use one of the installation methods in the linked uv documentation.
From the repository root, install the locked dependencies:

```bash
uv sync --locked
```

uv creates `.venv/` and uses Python 3.11 from `.python-version`, downloading Python
if needed. Run all ESPHome commands with `uv run`; no environment activation or
`source` command is needed. `uv run` also syncs dependencies automatically, so the
initial `uv sync` is optional. Existing `venv/` directories are no longer used;
if you have one active, run `deactivate` once before switching to this workflow.

If `secrets.yaml` is absent, copy `secrets.yaml.example` to it and configure your
credentials. The BLE variant also needs an `api_encryption_key` entry, which is
currently missing from the example. Never commit `secrets.yaml`.

Dependencies are declared in `pyproject.toml`; `uv.lock` records the exact resolved
versions. ESPHome is pinned to `2026.3.0`, matching the environment used before
this migration. The uv configuration also retains `cbor2 5.8.0` from that
environment to avoid the Rust build required by `cbor2 6.1.5` on Intel macOS.
To intentionally upgrade ESPHome, run `uv add 'esphome==<version>'`,
validate both firmware configurations, and commit both dependency files.

Validate configuration or compile without uploading firmware:

```bash
uv run esphome config train-pusher-client.yaml
uv run esphome config train-pusher-ble.yaml
uv run esphome compile train-pusher-client.yaml
uv run esphome compile train-pusher-ble.yaml
```

Firmware upload
---------------

> **NOTE:** First time upload should be performed via cable, all subsequent uploads could be performed Over-The-Air (OTA upload)

To build and upload firmware, complete the [Project configuration](#project-configuration) above, then run:
```bash
uv run esphome run train-pusher-client.yaml
```

In order to check device logs run:
```bash
uv run esphome logs train-pusher-client.yaml
```

More details on ESPHome usage could be found via `uv run esphome -h` command and on [the official website](https://esphome.io/)

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
uv run esphome run train-pusher-ble.yaml
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
