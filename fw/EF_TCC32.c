#ifndef EF_TCC32_C
#define EF_TCC32_C
#include <EF_TCC32.h>

void EF_TCC_tmrEn(uint32_t tcc32_base, bool is_en){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    if (is_en)
        tcc32->control |= 0x3;
    else
        tcc32->control &= ~0x3;
}

void EF_TCC_cpEn(uint32_t tcc32_base, bool is_en){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    if (is_en)
        tcc32->control |= 0x9;
    else
        tcc32->control &= ~0x9;
}

void EF_TCC_setClkSrc(uint32_t tcc32_base, int clk_src){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    int tmp = clk_src << 8;
    tmp = tmp & 0xF00;
    tcc32->control |= tmp;
}

void EF_TCC_timerUp(uint32_t tcc32_base, bool is_up){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    if (is_up)
        tcc32->control |= 0x10000;
    else
        tcc32->control &= ~0x10000;
}

void EF_TCC_timerOneShot(uint32_t tcc32_base, bool is_one_shot){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    if (is_one_shot)
        tcc32->control |= 0x20000;
    else
        tcc32->control &= ~0x20000;
}

void EF_TCC_setCpEvent(uint32_t tcc32_base, int cp_event){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    // cp event 
    tcc32->control &= ~0x3000000;
    int tmp = cp_event << 24;
    tmp = tmp & 0x3000000;
    tcc32->control |= tmp;
}

void EF_TCC_captureRising(uint32_t tcc32_base){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    EF_TCC_setCpEvent(tcc32_base, 0x1);
}

void EF_TCC_captureFalling(uint32_t tcc32_base){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    EF_TCC_setCpEvent(tcc32_base, 0x2);
}
void EF_TCC_captureBoth(uint32_t tcc32_base){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    EF_TCC_setCpEvent(tcc32_base, 0x3);
}

void EF_TCC_setCounterMatch(uint32_t tcc32_base, int match){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    tcc32->counter_match = match;
}

void EF_TCC_setTimerPeriod(uint32_t tcc32_base, int period){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    tcc32->period = period;
}

int EF_TCC_getTimerPeriod(uint32_t tcc32_base){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    return (tcc32->timer);
}

int EF_TCC_getCounterVal(uint32_t tcc32_base){

    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    return (tcc32->control);
}


void EF_TCC_setInterruptMask(uint32_t tcc32_base, int mask){
    // bit 0: Time-out Flag
    // bit 1: Capture Flag
    // bit 2: Match Flag
    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    tcc32->im = mask;
}

void EF_TCC_clearInterrupt(uint32_t tcc32_base, int mask){
    // bit 0: Time-out Flag
    // bit 1: Capture Flag
    // bit 2: Match Flag
    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    tcc32->icr = mask;
}

unsigned int EF_TCC_readRIS(uint32_t tcc32_base){
    EF_TCC32_TYPE* tcc32 = (EF_TCC32_TYPE*)tcc32_base;
    return (tcc32->ris);
}

#endif // EF_TCC32_C