ESP8266 Client for the Train Pusher
===================================

ESP8266 FreeRTOS based client for the [Train Pusher](https://github.com/vi7/train-pusher)

Project configuration
---------------------

Install ESP toolchain and SDK:
```bash
./setup.sh
```

Then start project configuration utility by running `make menuconfig`. In the menu, navigate to `Serial flasher config` > `Default serial port` to configure the serial port, where project will be loaded to. Confirm selection by pressing enter, save configuration by selecting `< Save >` and then exit application by selecting `< Exit >`.


Development
-----------

Cloning the project and submodules:
```bash
git clone --recurse-submodules https://github.com/vi7/train-pusher-client.git
```

Updating submodules:
```bash
git submodule update --init --recursive
# OR if changes already fetched and visible in the status:
git submodule update --remote
```

Working on a submodule:
```bash
# update local submodule branch by rebasing:
git submodule update --remote --rebase
```

Compile project: `make all`

Compile and flash: `make flash`

Viewing serial output: `make monitor`

Serial monitor hotkeys: Quit: Ctrl+] | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H

Build just the app: `make app`

Flash just the app: `make app-flash` - will automatically rebuild the app if it needs it

Speed up build with compiling multiple files in parallel: `make -jN app-flash` - where N is the number of parallel make processes to run (generally N should be equal to or one more than the number of CPU cores in your system.)

Erase the entire flash: `make erase_flash`

Make targets could be combined in one run
