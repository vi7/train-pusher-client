# Train Pusher Client

ESPHome-based physical control panel for controlling a Lego Duplo train via Bluetooth. This client communicates with the [train-pusher](https://github.com/vi7/train-pusher) Node.js backend, which handles the actual Bluetooth Low Energy (BLE) communication with the train.

## ⚠️ IMPORTANT SAFETY NOTES

**READ THIS BEFORE MAKING ANY CHANGES**

1. **ALWAYS activate Python virtualenv** before running ANY ESPHome commands:
   ```bash
   source venv/bin/activate
   ```
   Running `pip install` or ESPHome commands without activating virtualenv can corrupt your system Python installation.

2. **NEVER commit `secrets.yaml`** to version control
   - Contains WiFi passwords, API credentials, and OTA passwords
   - Already listed in `.gitignore` - verify before committing
   - Use `secrets.yaml.example` as a template

3. **First firmware flash MUST be via USB cable**
   - Initial deployment requires physical access to D1 Mini
   - After first flash, OTA (Over-The-Air) updates can be used
   - Keep USB cable accessible in case OTA fails

4. **Test backend connectivity before deploying firmware**
   - Verify train-pusher backend is running on configured IP:port
   - Check network connectivity: `curl http://192.168.1.12:8080/api/v1/`
   - Device will attempt to call backend on every button press

5. **Verify static IP configuration doesn't conflict**
   - Default device IP: 192.168.1.31
   - Ensure no other device uses this IP on your network
   - Update in `train-pusher-client.yaml` if conflict exists

## Project Overview

**Hardware**: ESP8266 (D1 Mini) + TLC5947 LED driver + physical buttons
**Firmware**: ESPHome
**Backend**: Node.js HTTP server (train-pusher)
**Communication**: HTTP REST API

## Architecture

```
Physical Buttons → ESP8266 → HTTP API → Node.js Backend → BLE → Lego Duplo Train
                        ↓
                   LED Feedback
```

## Hardware Setup

### Components
- **Microcontroller**: D1 Mini (ESP8266)
- **LED Controller**: TLC5947 (24-channel PWM driver)
- **Buttons**: 6 physical buttons with integrated LEDs
- **Network**: WiFi connection (static IP: 192.168.1.31)

### Button Mappings

| Button | GPIO Pin | TLC5947 LED Channel | Function | API Endpoint |
|--------|----------|---------------------|----------|--------------|
| Green Forward | 12 | 23 | Move train forward | `/api/v1/fwdpowerup` |
| Green Backward | 5 | 22 | Move train backward | `/api/v1/backpowerup` |
| Red | 0 | 20 | Stop train | `/api/v1/stop` |
| Blue | 2 | 17 | Brake train | `/api/v1/brake` |
| Yellow | 14 | 18 | Play sounds (short/long press) | `/api/v1/sound/{id}` |
| White | 4 | 19 | LED control (short=cycle, long=off) | `/api/v1/ledchangecolor` or `/api/v1/led/0` |

### TLC5947 LED Driver Pins
- **Data Pin**: GPIO 15
- **Clock Pin**: GPIO 16
- **Latch Pin**: GPIO 13

## Configuration

### Backend Connection

Edit `train-pusher-client.yaml` substitutions section:

```yaml
substitutions:
  backend_address: "192.168.1.12"  # IP of machine running train-pusher backend
  backend_port: "8080"
  backend_ver: v1
```

### WiFi & Secrets

Copy `secrets.yaml.example` to `secrets.yaml` and configure:

```yaml
wifi_ssid: "your-network-name"
wifi_password: "your-wifi-password"
ap_password: "fallback-hotspot-password"
ha_api_password: "home-assistant-api-password"
ota_password: "over-the-air-update-password"
```

**Note**: `secrets.yaml` is git-ignored to prevent credential leakage.

### Network Configuration

The device uses a static IP configuration in `train-pusher-client.yaml`:
- **IP Address**: 192.168.1.31
- **Gateway**: 192.168.1.1
- **Subnet**: 255.255.255.0
- **DNS**: 192.168.1.1, 192.168.1.4

Adjust these values to match your network setup.

## Development Workflow

### Prerequisites

```bash
# Create Python virtual environment
python3 -m pip install virtualenv
python3 -m virtualenv venv

# Activate virtualenv (REQUIRED for all ESPHome commands)
source venv/bin/activate

# Install ESPHome
pip install -r requirements.txt
```

**Important**: Always activate the virtualenv with `source venv/bin/activate` before using ESPHome commands.

### Building and Flashing

```bash
# Build and upload firmware
esphome run train-pusher-client.yaml

# View logs
esphome logs train-pusher-client.yaml

# Validate configuration
esphome config train-pusher-client.yaml

# Compile only (no upload)
esphome compile train-pusher-client.yaml
```

**First Flash**: Must be done via USB cable. All subsequent updates can be done Over-The-Air (OTA).

### OTA Updates

After initial USB flash, you can update wirelessly:

```bash
esphome run train-pusher-client.yaml
# Select OTA option when prompted
```

## API Endpoints (Backend)

The device calls these endpoints on the train-pusher backend:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/fwdpowerup` | GET | Accelerate forward |
| `/api/v1/backpowerup` | GET | Accelerate backward |
| `/api/v1/stop` | GET | Stop train |
| `/api/v1/brake` | GET | Emergency brake |
| `/api/v1/sound/{id}` | GET | Play train sound (3=brake, 5=departure, 7=water, 9=horn, 10=steam) |
| `/api/v1/ledchangecolor` | GET | Cycle LED color |
| `/api/v1/led/{color}` | GET | Set LED color (0=off, 1-10=colors, 255=none) |

## Button Behavior

### Green Forward/Backward
- **Action**: Single press
- **Effect**: Lights corresponding LED, turns off opposite direction LED, sends acceleration command

### Red Stop
- **Action**: Single press
- **Effect**: Turns off direction LEDs, lights red LED for 1.5s, stops train

### Blue Brake
- **Action**: Single press
- **Effect**: Turns off direction LEDs, lights blue LED for 1.5s, emergency brake

### Yellow Sound
- **Short Press** (150-350ms): Play station departure sound (ID 5)
- **Long Press** (700-5000ms): Play water refill sound (ID 7)

### White LED Control
- **Short Press** (50-350ms): Cycle through LED colors
- **Long Press** (700-5000ms): Turn LED off

## Home Assistant Integration

The device is compatible with Home Assistant via the ESPHome API:
- **API Password**: Configured in `secrets.yaml` as `ha_api_password`
- **Device Name**: `train-pusher-client`

## Troubleshooting

### Device Not Connecting to WiFi
- Check `secrets.yaml` credentials
- Verify network settings (static IP not conflicting)
- Device will create fallback hotspot "Train-Pusher-Client" if WiFi fails

### Backend Not Responding
- Verify backend is running on configured IP:port
- Check backend logs for incoming requests
- Ensure firewall allows connections on port 8080
- HTTP timeout is set to 2 seconds

### Buttons Not Working
- Check pin assignments in `train-pusher-client.yaml`
- Verify GPIO connections to D1 Mini
- Review logs with `esphome logs train-pusher-client.yaml`
- Buttons are configured as inverted (active low) without internal pullups

### LEDs Not Lighting
- Verify TLC5947 connections (data=GPIO15, clock=GPIO16, latch=GPIO13)
- Check channel assignments in output section
- Ensure TLC5947 has proper power supply

## Related Projects

- **Backend**: [train-pusher](https://github.com/vi7/train-pusher) - Node.js BLE controller
- **ESPHome**: [esphome.io](https://esphome.io/) - Official documentation

## Development Notes

### ESPHome Version
The project uses ESPHome as specified in `requirements.txt`. Update by modifying the requirements file and reinstalling:

```bash
pip install -r requirements.txt --upgrade
```

### Build Artifacts
- `.esphome/` - Build cache and compiled binaries (git-ignored)
- `venv/` - Python virtual environment (git-ignored)

### Making Changes
1. Edit `train-pusher-client.yaml` for configuration changes
2. Validate: `esphome config train-pusher-client.yaml`
3. Upload: `esphome run train-pusher-client.yaml` (OTA or USB)
4. Monitor: `esphome logs train-pusher-client.yaml`

## Quick Reference

```bash
# Activate environment (REQUIRED - see Safety Notes above!)
source venv/bin/activate

# Full rebuild and flash
esphome run train-pusher-client.yaml

# Monitor logs
esphome logs train-pusher-client.yaml

# Deactivate environment
deactivate
```
