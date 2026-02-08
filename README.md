Client for the Duplo Train Pusher
=================================

[ESPHome](https://esphome.io/) client for the [Duplo Train Pusher](https://github.com/vi7/train-pusher) backend

**Table of Contents**

- [Project configuration](#project-configuration)
- [Firmware upload](#firmware-upload)
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
