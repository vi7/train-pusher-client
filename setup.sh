#!/usr/bin/env bash

# ESP8266 FreeRTOS project configuration script

set -e

# Script failure catcher
trap 'catch $?' EXIT
catch() {
  if [ "$1" != 0 ]
  then
    # This will execute on any non-zero exit of the script
    cleanup
  fi
}


PROJECT_DIR=$(basename "$(dirname "$0")")
TMPDIR=""
TOOLCHAIN_ARCHIVE_NAME="xtensa-lx106-elf-gcc8_4_0-esp-2020r3-macos.tar.gz"
TOOLCHAIN_INSTALLATION_PREFIX="/usr/local"
TOOLCHAIN_COMPILER_PATH="$TOOLCHAIN_INSTALLATION_PREFIX/bin/xtensa-lx106-elf-gcc"
RTOS_SDK_NAME="ESP8266_RTOS_SDK"
RTOS_SDK_VERSION="3.4"
RTOS_SDK_INSTALLATION_PREFIX="$HOME/.local/sdk"


create_temp() {
  TMPDIR=$(mktemp -d -t "${PROJECT_DIR}")
}

install_toolchain() {
  if ! $TOOLCHAIN_COMPILER_PATH --version >/dev/null 2>&1
  then
    curl -L https://dl.espressif.com/dl/$TOOLCHAIN_ARCHIVE_NAME | \
      sudo tar --strip-components 1 -xzvf - -C $TOOLCHAIN_INSTALLATION_PREFIX
  else
    printf "\e[33m[WARN] Skipping xtensa-lx106-elf toolchain installation. Already installed to %s\e[0m\n" $TOOLCHAIN_INSTALLATION_PREFIX
  fi
}

install_sdk() {
  if [ ! -d "$RTOS_SDK_INSTALLATION_PREFIX/$RTOS_SDK_NAME" ]
  then
    mkdir -p "$RTOS_SDK_INSTALLATION_PREFIX"
    git clone --recurse-submodules --branch release/v$RTOS_SDK_VERSION https://github.com/espressif/$RTOS_SDK_NAME.git "$RTOS_SDK_INSTALLATION_PREFIX/$RTOS_SDK_NAME"
    # Uncomment below to install needed Python packages globally for the current user - NOT RECOMMENDED
    #python3 -m pip install --user -r "$RTOS_SDK_INSTALLATION_PREFIX"/$RTOS_SDK_NAME/requirements.txt
    printf "\n\e[33;1mAdd \"export IDF_PATH=%s/%s\" to the user profile\e[0m\n\n" "$RTOS_SDK_INSTALLATION_PREFIX" $RTOS_SDK_NAME
  else
    printf "\e[33m[WARN] Skipping ESP8266 RTOS SDK installation. Already installed to %s/%s\e[0m\n" "$RTOS_SDK_INSTALLATION_PREFIX" $RTOS_SDK_NAME
  fi
}

configure_vscode_project() {
  echo "[INFO] Configuring VSCode project"
  mkdir -p .vscode
  cat > .vscode/c_cpp_properties.json <<EOF
{
    "env": {
        "idfPath": "$RTOS_SDK_INSTALLATION_PREFIX/$RTOS_SDK_NAME"
      },
    "configurations": [
        {
            "name": "ESP8266_RTOS_SDK",
            "includePath": [
                "\${idfPath}/components/**",
                "\${workspaceRoot}/main/**",
                "\${workspaceRoot}/components/**", // comes in handy when first components are created
                "\${workspaceRoot}/build/include"
            ],
            "compilerPath": "$TOOLCHAIN_COMPILER_PATH",
            "cStandard": "c17",
            "cppStandard": "c++17"
        }
    ],
    "version": 4
}
EOF

}

cleanup() {
  rm -rf "$TMPDIR"
}

main() {
  # create_temp
  install_toolchain
  install_sdk
  configure_vscode_project
  cleanup
}

main "$@"
