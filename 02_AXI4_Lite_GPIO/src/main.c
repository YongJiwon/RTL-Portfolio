
#include "xil_printf.h"
#include "ap/StopWatch.h"
#include "common/delay/delay.h"



int main()
{

    StopWatch_Init();

    while (1)
    {
    	StopWatch_Excute();
        FND_Excute(0);
        incTick();
        delay_ms(1);
    }

    return 0;
}
