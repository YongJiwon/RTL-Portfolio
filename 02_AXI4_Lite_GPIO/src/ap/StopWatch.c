#include "StopWatch.h"

stopwatch_e stopWatchState;
uint32_t stopWatchLed;
uint32_t stopWatchStateLed;
uint32_t counter;
stopWatch_t stopWatchTimeData;


void StopWatch_Init()
{
	LED_Init();
	FND_Init();
	Button_Init();

	stopWatchState = STOP;
	counter = 0;
	stopWatchLed = 0x01;
	stopWatchStateLed = 0;
//	/stopWatchTimeData =0;
}


void StopWatch_ClearTime()
{
	stopWatchTimeData.hour =0;
	stopWatchTimeData.min = 0;
	stopWatchTimeData.sec = 0;
	stopWatchTimeData.ms= 0;
}

void StopWatch_IncTime()
{
	if(stopWatchTimeData.ms == 99){
		stopWatchTimeData.ms = 0;
	}
	else{
		stopWatchTimeData.ms++;
		return;
	}

	if(stopWatchTimeData.sec == 59){
		stopWatchTimeData.sec = 0;
	}
	else{
		stopWatchTimeData.sec++;
		return;
	}

	if(stopWatchTimeData.min == 59){
		stopWatchTimeData.min = 0;
	}
	else{
		stopWatchTimeData.min++;
		return;
	}

	if(stopWatchTimeData.hour == 23){
		stopWatchTimeData.hour = 0;
	}
	else{
		stopWatchTimeData.hour++;
		return;
	}
}

void StopWatch_RunTime()
{
	static uint32_t prevTime = 0;
	uint32_t curTime = millis();

	if(curTime - prevTime < 10) return;
	prevTime = curTime;

	if(stopWatchState == RUN)
	{
		counter++;
		StopWatch_IncTime();
	}





}

void StopWatch_Excute()
{
    StopWatch_RunTime();
    StopWatch_ControlState();
    StopWatch_DispWatch();
    StopWatch_ControlLed();
}

void StopWatch_DispWatch()
{
    if(stopWatchTimeData.ms % 10 < 5)
        FND_SetDP(FND_DIGIT_1, FND_DP_ON);
    else
        FND_SetDP(FND_DIGIT_1, FND_DP_OFF);

    if(stopWatchTimeData.ms < 50)
        FND_SetDP(FND_DIGIT_3, FND_DP_ON);
    else
        FND_SetDP(FND_DIGIT_3, FND_DP_OFF);

    FND_SetNum((stopWatchTimeData.min % 10) * 1000 +
               (stopWatchTimeData.sec / 10) * 100 +
               (stopWatchTimeData.sec % 10) * 10 +
               (stopWatchTimeData.ms / 10));

    StopWatch_ControlLed();
}

void StopWatch_ControlState()
{
	switch(stopWatchState)
	{
	case STOP:
		if(Button_GetState(&hbtnRunStop) == ACT_PUSHED)
		{
			stopWatchState = RUN;
		}
		else if(Button_GetState(&hbtnClear) == ACT_PUSHED)
		{
			stopWatchState = CLEAR;
		}
		break;

	case RUN:
		if(Button_GetState(&hbtnRunStop) == ACT_PUSHED)
		{
			stopWatchState = STOP;
		}
		break;

	case CLEAR:
	    counter = 0;
		StopWatch_ClearTime();
		stopWatchState = STOP;
		break;

	default:
		stopWatchState = STOP;
		break;
	}
}



void StopWatch_RunLed()
{
	static uint32_t prevTime = 0;
	uint32_t curTime = millis();

	if(curTime - prevTime < 100) return;
	prevTime = curTime;

	stopWatchLed = (stopWatchLed <<1) | (stopWatchLed >>15);
	stopWatchLed &=0xffff;
	//LED_WritePort8(LED_LOW_GPIO, stopWatchLed);
	LED_WritePort16(stopWatchLed);
}

void StopWatch_StopLed()
{


	stopWatchStateLed |= (1 << STOP_STATE_LED);
	stopWatchStateLed &= ~(1 << RUN_STATE_LED);
	//LED_WritePort8(LED_HI_GPIO, stopWatchStateLed);
	LED_WritePort16(stopWatchStateLed);

}


void StopWatch_ClearLed()
{
	stopWatchLed = 0x01;
	LED_WritePort8(LED_LOW_GPIO, stopWatchLed);
}





void StopWatch_ControlLed()
{
	switch (stopWatchState)

	{
	case STOP:
		StopWatch_StopLed();
		break;
	case RUN:
		StopWatch_RunLed();
		break;
	case CLEAR:
		StopWatch_ClearLed();
		break;
	default:
		break;
	}


}


