localparam[15:0] TIMER_REG_ADDR = 16'h0000;
localparam[15:0] PERIOD_REG_ADDR = 16'h0004;
localparam[15:0] COUNTER_REG_ADDR = 16'h0008;
localparam[15:0] COUNTER_MATCH_REG_ADDR = 16'h000c;
localparam[15:0] CONTROL_REG_ADDR = 16'h0010;
localparam[15:0] ICR_REG_ADDR = 16'h0f00;
localparam[15:0] RIS_REG_ADDR = 16'h0f04;
localparam[15:0] IM_REG_ADDR = 16'h0f08;
localparam[15:0] MIS_REG_ADDR = 16'h0f0c;

localparam  CTRL_EN = 1,
            CTRL_TMR_EN = 2,
            CTRL_CP_EN = 8,
            CTRL_COUNT_UP = 32'h10000,
            CTRL_MODE_ONESHOT = 32'h20000,
            CTRL_CLKSRC_EXT = 32'h900,
            CTRL_CLKSRC_DIV1 = 32'h800,
            CTRL_CLKSRC_DIV2 = 32'h000,
            CTRL_CLKSRC_DIV4 = 32'h100,
            CTRL_CLKSRC_DIV256 = 32'h70,
            CTRL_CPEVENT_PE = 32'h1_00_0000,
            CTRL_CPEVENT_NE = 32'h2_00_0000,
            CTRL_CPEVENT_BE = 32'h3_00_0000;
                
localparam  INT_TO_FLAG = 1,
            INT_MATCH_FLAG = 4,
            INT_CP_FLAG	= 2;
