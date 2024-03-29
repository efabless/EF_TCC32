/*
	Copyright 2023 Efabless Corp.

	Author: Mohamed Shalan (mshalan@efabless.com)

	This file is auto-generated by wrapper_gen.py on 2023-11-26

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	    http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

*/
#ifndef EF_TCC32_REGS_H
#define EF_TCC32_REGS_H

#ifndef IO_TYPES
#define IO_TYPES
#define   __R     volatile const unsigned int
#define   __W     volatile       unsigned int
#define   __RW    volatile       unsigned int
#endif

#define EF_TCC32_CONTROL_REG_EN		0
#define EF_TCC32_CONTROL_REG_EN_LEN	1
#define EF_TCC32_CONTROL_REG_TIMER_EN		1
#define EF_TCC32_CONTROL_REG_TIMER_EN_LEN	1
#define EF_TCC32_CONTROL_REG_CP_EN		3
#define EF_TCC32_CONTROL_REG_CP_EN_LEN	1
#define EF_TCC32_CONTROL_REG_CLK_SRC		8
#define EF_TCC32_CONTROL_REG_CLK_SRC_LEN	4
#define EF_TCC32_CONTROL_REG_UP_DOWN		16
#define EF_TCC32_CONTROL_REG_UP_DOWN_LEN	1
#define EF_TCC32_CONTROL_REG_ONE_SHOT		17
#define EF_TCC32_CONTROL_REG_ONE_SHOT_LEN	1
#define EF_TCC32_CONTROL_REG_CP_EVENT		24
#define EF_TCC32_CONTROL_REG_CP_EVENT_LEN	2
#define EF_TCC32_TO_FLAG	0x1
#define EF_TCC32_CP_FLAG	0x2
#define EF_TCC32_MATCH_FLAG	0x4

typedef struct _EF_TCC32_TYPE_ {
	__R 	timer;
	__RW	period;
	__R 	counter;
	__RW	counter_match;
	__RW	control;
	__R 	reserved[955];
	__W 	icr;
	__R 	ris;
	__RW	im;
	__R 	mis;
} EF_TCC32_TYPE;

#endif