/**
 * @brief: main application test file
 */

#include <stdio.h>
#include "stm32f429i_discovery.h"
#include "stm32f429i_discovery_lcd.h"


/** Flash bank adresses */
#define BANK_1_FLASH_ADDRESS 0x08000000
#define BANK_2_FLASH_ADDRESS 0x08000000



/**
 * @brief main application entry point
 */
void main (void)
{
    /* inits the systick base time */
    HAL_SYSTICK_Config(SystemCoreClock / 1000);

    BSP_LED_Init(LED3);
    BSP_LED_Init(LED4);
    BSP_LED_On(LED4);

    BSP_LCD_Init();
    BSP_LCD_DisplayOff();
    BSP_LCD_LayerDefaultInit(LCD_BACKGROUND_LAYER, LCD_FRAME_BUFFER);
    BSP_LCD_LayerDefaultInit(LCD_FOREGROUND_LAYER, LCD_FRAME_BUFFER + BUFFER_OFFSET);
    BSP_LCD_SelectLayer(LCD_BACKGROUND_LAYER);
    BSP_LCD_DisplayOn();

    for(;;) {
        int i = 0xFFFF;
        BSP_LED_Toggle(LED3);
        BSP_LED_Toggle(LED4);
        while(--i);
    }
}
