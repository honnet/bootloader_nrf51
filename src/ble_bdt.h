#ifndef BLE_BDT_H__
#define BLE_BDT_H__

#include <stdint.h>
#include <stdbool.h>
#include "ble.h"
#include "ble_srv_common.h"

#define BDT_UUID_BASE {0x23, 0xD1, 0xBC, 0xEA, 0x5F, 0x78, 0x23, 0x15, 0xDE, 0xEF, 0x12, 0x12, 0x00, 0x00, 0x00, 0x00}
#define BDT_UUID_SERVICE 0x1523
#define BDT_UUID_CHAR 0x1525

// Forward declaration of the ble_bdt_t type.
typedef struct ble_bdt_s ble_bdt_t;

typedef void (*ble_write_handler_t) (ble_bdt_t * p_bdt, uint8_t new_state);

typedef struct
{
    ble_write_handler_t command_handler;                    /**< Event handler to be called when characteristic is written. */
} ble_bdt_init_t;

/**@brief Service structure. This contains various status information for the service. */
typedef struct ble_bdt_s
{
    uint16_t                    service_handle;
    ble_gatts_char_handles_t    char_handles;
    uint8_t                     uuid_type;
    uint16_t                    conn_handle;
    ble_write_handler_t command_handler;
} ble_bdt_t;

/**@brief Function for initializing the Service.
 *
 * @param[out]  p_bdt       Service structure. This structure will have to be supplied by
 *                          the application. It will be initialized by this function, and will later
 *                          be used to identify this particular service instance.
 * @param[in]   p_bdt_init  Information needed to initialize the service.
 *
 * @return      NRF_SUCCESS on successful initialization of service, otherwise an error code.
 */
uint32_t ble_bdt_init(ble_bdt_t * p_bdt, const ble_bdt_init_t * p_bdt_init);

/**@brief Function for handling the Application's BLE Stack events.
 *
 * @details Handles all events from the BLE stack of interest to the Service.
 *
 *
 * @param[in]   p_bdt      Service structure.
 * @param[in]   p_ble_evt  Event received from the BLE stack.
 */
void ble_bdt_on_ble_evt(ble_bdt_t * p_bdt, ble_evt_t * p_ble_evt);

#endif // BLE_BDT_H__

/** @} */
