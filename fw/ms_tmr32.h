/*


*/

#define MS_TMR32_BASE   0x10000000

#define TMR_REG_ADDR        (MS_TMR32_BASE +  0x00)
#define PERIOD_REG_ADDR     (MS_TMR32_BASE +  0x04)
#define PWMCMP_REG_ADDR     (MS_TMR32_BASE +  0x08)
#define MATCH_REG_ADDR      (MS_TMR32_BASE +  0x0C)
#define COUNTER_REG_ADDR    (MS_TMR32_BASE +  0x10,)
#define CTRL_REG_ADDR       (MS_TMR32_BASE +  0x100)
#define RIS_REG_ADDR        (MS_TMR32_BASE +  0x200)
#define MIS_REG_ADDR        (MS_TMR32_BASE +  0x204)
#define IM_REG_ADDR         (MS_TMR32_BASE +  0x208)
#define ICR_REG_ADDR        (MS_TMR32_BASE +  0x20C)
    
#define CTRL_EN             0x1
#define CTRL_TMR_EN         0x2
#define CTRL_PWM_EN         0x4
#define CTRL_COUNTER_EN     0x8
#define CTRL_CLK_SRC_CLK2   0x000
#define CTRL_CLK_SRC_CLK4   0x100
#define CTRL_CLK_SRC_CLK8   0x200
#define CTRL_CLK_SRC_CLK16  0x300
#define CTRL_CLK_SRC_CLK32  0x400
#define CTRL_CLK_SRC_CLK64  0x500
#define CTRL_CLK_SRC_CLK128 0x600
#define CTRL_CLK_SRC_CLK256 0x700
#define CTRL_CLK_SRC_CLK    0x800
#define CTRL_CLK_SRC_EXTCTR 0x900
#define CTRL_UP             0x10000
#define CTRL_ONE_SHOT       0x20000
#define CTRL_EVENT_POS      0x1000000
#define CTRL_EVENT_NEG      0x2000000
#define CTRL_EVENT_BOTH     0x3000000
