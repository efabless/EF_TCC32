#ifndef EF_TCC32_H
#define EF_TCC32_H

#include <EF_TCC32_regs.h>
#include <stdint.h>
#include <stdbool.h>

void EF_TCC_tmrEn(uint32_t tcc32_base, bool is_en);

void EF_TCC_cpEn(uint32_t tcc32_base, bool is_en);

void EF_TCC_setClkSrc(uint32_t tcc32_base, int clk_src);

void EF_TCC_timerUp(uint32_t tcc32_base, bool is_up);

void EF_TCC_timerOneShot(uint32_t tcc32_base, bool is_one_shot);

void EF_TCC_setCpEvent(uint32_t tcc32_base, int cp_event);

void EF_TCC_captureRising(uint32_t tcc32_base);

void EF_TCC_captureFalling(uint32_t tcc32_base);

void EF_TCC_captureBoth(uint32_t tcc32_base);

void EF_TCC_setCounterMatch(uint32_t tcc32_base, int match);

void EF_TCC_setTimerPeriod(uint32_t tcc32_base, int period);

int EF_TCC_getTimerPeriod(uint32_t tcc32_base);

int EF_TCC_getCounterVal(uint32_t tcc32_base);

void EF_TCC_setInterruptMask(uint32_t tcc32_base, int mask);

void EF_TCC_clearInterrupt(uint32_t tcc32_base, int mask);

unsigned int EF_TCC_readRIS(uint32_t tcc32_base);

#endif
