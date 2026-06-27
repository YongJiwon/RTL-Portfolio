#ifndef SRC_DRIVER_BUTTON_BUTTON_H_
#define SRC_DRIVER_BUTTON_BUTTON_H_
#include "../../HAL/GPIO/GPIO.h"
#include "../../common/delay/delay.h"
#include <stdint.h>


typedef enum {
    NO_ACT = 0,
    ACT_PUSHED,
    ACT_RELEASED
} button_status_e;

typedef enum {
    RELEASED = 0,
    PUSHED
} button_state_e;

typedef struct {
    GPIO_TypeDef *GPIOx;
    uint32_t gpio_pin;
    button_state_e prevState;
} hbutton;




void Button_Init();
void Button_SetInit(hbutton *hbtn, GPIO_TypeDef *GPIOx, uint32_t gpio_pin);
button_status_e Button_GetState(hbutton *hbtn);
extern hbutton hbtnRunStop, hbtnClear;

#endif /* SRC_DRIVER_BUTTON_BUTTON_H_ */
