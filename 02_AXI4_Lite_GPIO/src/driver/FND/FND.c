#include "FND.h"

uint32_t fndNumber = 0;
uint32_t fndDPData = 0;

void FND_Init()
{
	uint32_t fndComTemp = GPIO_GetCR(GPIOB);
	fndComTemp |= 0x0f;
	GPIO_SetMode(FND_COM_GPIO, fndComTemp);

	GPIO_SetMode(FND_DATA_GPIO, 0xff);
}


void FND_SetNum(uint32_t num)
{
	fndNumber = num;
}

void FND_Excute(uint8_t sel)
{
	if(sel == 0) FND_DispNum(fndNumber);
	else if(sel == 1) FND_DispTime(fndNumber);
	else FND_DispNum(fndNumber);
}


void FND_SelDigit(uint32_t digit)
{
	uint32_t digitPos;
	digitPos  = GPIO_GetODR(FND_COM_GPIO);
	digitPos  = (digitPos | 0x0f) & ~(1<<digit);

	GPIO_WritePort(FND_COM_GPIO, digitPos);

}







void FND_DispAllOff()
{
    uint32_t digitPos;

    digitPos = GPIO_GetODR(FND_COM_GPIO);
    digitPos |= 0x0f;

    GPIO_WritePort(FND_COM_GPIO, digitPos);
}


void FND_SetDP(uint32_t fndDigitSel, uint32_t fndDpState)
{
	if(fndDpState == FND_DP_ON)
	{
		fndDPData |= 1<<fndDigitSel;
	}
	else
	{
		fndDPData &= ~(1<<fndDigitSel);
	}

}

void FND_DispDigit(uint32_t num, uint8_t dot)
{
    uint8_t fndFont[16] = {
        0xc0, 0xf9, 0xa4, 0xb0,
        0x99, 0x92, 0x82, 0xf8,
        0x80, 0x90, 0x88, 0x83,
        0xc6, 0xa1, 0x86, 0x8e
    };

    uint8_t data;

    if(dot) {
    	data = fndFont[num] & ~(0x80);
    }
    else{
    	data = fndFont[num] |  (0x80);
    }

    GPIO_WritePort(FND_DATA_GPIO, data);
}
/*void FND_DispDigit(uint32_t num)
{

	uint8_t fndFont[16] = {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8,
			0x80, 0x90, 0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e};

	GPIO_WritePort(FND_DATA_GPIO, fndFont[num%10]);

}*/

void FND_DispTime(uint32_t counter)
{
    static uint32_t fndDigitState = 0;

    uint32_t min;
    uint32_t sec;
    uint32_t tenth;

    min = counter / 600;          // 0.1초 단위 기준, 600 = 60초
    sec = (counter / 10) % 60;    // 초
    tenth = counter % 10;         // 0.1초

    fndDigitState = (fndDigitState + 1) % 4;

    FND_DispAllOff();
    uint8_t dot01s = counter % 2;
    uint8_t dot05s = (counter / 5) % 2;
    switch(fndDigitState)
    {
    case 0:
        FND_SelDigit(FND_DIGIT_3);
        FND_DispDigit(min, dot05s);        // 분 + dot
        break;

    case 1:
        FND_SelDigit(FND_DIGIT_2);
        FND_DispDigit(sec / 10, 0);   // 초 십의 자리
        break;

    case 2:
        FND_SelDigit(FND_DIGIT_1);
        FND_DispDigit(sec % 10, dot01s);   // 초 일의 자리 + dot
        break;

    case 3:
        FND_SelDigit(FND_DIGIT_0);
        FND_DispDigit(tenth, 0);      // 0.1초
        break;
    }
}

void FND_DispNum(uint32_t num)
{
	static uint32_t fndDigitState=0;
	fndDigitState = (fndDigitState +1)%4;
	FND_DispAllOff();
	switch(fndDigitState)
	{
	case 0:
		FND_SelDigit(FND_DIGIT_0);
		FND_DispDigit(num%10, fndDPData & 0x01);

		break;
	case 1:
		FND_SelDigit(FND_DIGIT_1);
		FND_DispDigit(num/10%10, fndDPData & 0x02);

		break;
	case 2:
		FND_SelDigit(FND_DIGIT_2);
		FND_DispDigit(num/100%10, fndDPData & 0x04);

		break;
	case 3:
		FND_SelDigit(FND_DIGIT_3);
		FND_DispDigit(num/1000%10, fndDPData & 0x08);

		break;
	}
}
