#ifndef SRC_HAL_GPIO_GPIO_H_
#define SRC_HAL_GPIO_GPIO_H_

#include <stdint.h>
#include "xparameters.h"


typedef struct {
	volatile uint32_t CR;   // Offset 0x00 : 방향 설정
	volatile uint32_t IDR;  // Offset 0x04 : 입력 데이터 읽기
	volatile uint32_t ODR;  // Offset 0x08 : 출력 데이터 쓰기
} GPIO_TypeDef;


#define GPIO_INPUT 0
#define GPIO_OUTPUT 1

#define GPIO_PIN_0	0x01
#define GPIO_PIN_1	0x02
#define GPIO_PIN_2	0x04
#define GPIO_PIN_3	0x08
#define GPIO_PIN_4	0x10
#define GPIO_PIN_5	0x20
#define GPIO_PIN_6	0x40
#define GPIO_PIN_7	0x80


#define GPIO_RESET	0
#define GPIO_SET	1
#define GPIOA ((GPIO_TypeDef *)XPAR_GPIO_0_S00_AXI_BASEADDR) // FND 세그먼트 데이터 (A~G, DP)
#define GPIOB ((GPIO_TypeDef *)XPAR_GPIO_1_S00_AXI_BASEADDR) // FND 자리선택(0:3) + 버튼/스위치 입력(4:7)
#define GPIOC ((GPIO_TypeDef *)XPAR_GPIO_2_S00_AXI_BASEADDR) // 우측 LED 8개 (출력)
#define GPIOD ((GPIO_TypeDef *)XPAR_GPIO_3_S00_AXI_BASEADDR) // 좌측 LED 8개 (출력)


void GPIO_SetMode(GPIO_TypeDef *GPIOx, int mode);
void GPIO_WritePort(GPIO_TypeDef *GPIOx, uint32_t data);
void GPIO_WritePin(GPIO_TypeDef *GPIOx, uint32_t gpio_pin, uint32_t gpio_pin_state);
uint32_t GPIO_ReadPort(GPIO_TypeDef *GPIOx);
uint32_t GPIO_ReadPin(GPIO_TypeDef *GPIOx, uint32_t gpio_pin);
uint32_t GPIO_GetODR(GPIO_TypeDef *GPIOx);
uint32_t GPIO_GetCR(GPIO_TypeDef *GPIOx);



#endif /* SRC_HAL_GPIO_GPIO_H_ */
