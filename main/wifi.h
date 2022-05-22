/* Common functions to establish Wi-Fi or Ethernet connection.

   Based on ESP8266 SDK examples
 */

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "esp_err.h"
#include "tcpip_adapter.h"
#include "secrets.h"

#define INTERFACE TCPIP_ADAPTER_IF_STA

/**
 * @brief Configure Wi-Fi or Ethernet, connect, wait for IP
 *
 * This all-in-one helper function is used in protocols examples to
 * reduce the amount of boilerplate in the example.
 *
 * It is not intended to be used in real world applications.
 * See examples under examples/wifi/getting_started/ and examples/ethernet/
 * for more complete Wi-Fi or Ethernet initialization code.
 *
 * Read "Establishing Wi-Fi or Ethernet Connection" section in
 * examples/protocols/README.md for more information about this function.
 *
 * @return ESP_OK on successful connection
 */
esp_err_t connect(void);

/**
 * Counterpart to connect, de-initializes Wi-Fi or Ethernet
 */
esp_err_t disconnect(void);

/**
 * @brief Configure stdin and stdout to use blocking I/O
 *
 * This helper function is used in ASIO examples. It wraps installing the
 * UART driver and configuring VFS layer to use UART driver for console I/O.
 */
esp_err_t configure_stdin_stdout(void);

/**
 * @brief Configure SSID and password
 */
esp_err_t set_connection_info(const char *ssid, const char *passwd);

#ifdef __cplusplus
}
#endif
