#ifndef SRC_AP_STOPWATCH_H_
#define SRC_AP_STOPWATCH_H_


#include "../driver/Button/Button.h"
#include "../driver/FND/FND.h"
#include "../driver/LED/LED.h"

#define STOP_STATE_LED	7
#define RUN_STATE_LED	5

typedef struct {
	uint8_t hour;
	uint8_t min;
	uint8_t sec;
	uint8_t ms;

}stopWatch_t;






void StopWatch_Init();
void StopWatch_ControlState();
void StopWatch_Excute();
void StopWatch_RunTime();
void StopWatch_ControlLed();
void StopWatch_ClearLed();
void StopWatch_RunLed();
void StopWatch_ClearTime();
void StopWatch_DispWatch();
typedef enum {
    STOP = 0,
    RUN,
    CLEAR
} stopwatch_e;

#endif /* SRC_AP_STOPWATCH_H_ */
