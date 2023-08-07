/*


*/

#define MS_TMR32_BASE                   0x10000000

#define MS_TMR32_TMR_REG_ADDR           (MS_TMR32_BASE +  0x00)
#define MS_TMR32_PERIOD_REG_ADDR        (MS_TMR32_BASE +  0x04)
#define MS_TMR32_PWMCMP_REG_ADDR        (MS_TMR32_BASE +  0x08)
#define MS_TMR32_MATCH_REG_ADDR         (MS_TMR32_BASE +  0x0C)
#define MS_TMR32_COUNTER_REG_ADDR       (MS_TMR32_BASE +  0x10,)
#define MS_TMR32_CTRL_REG_ADDR          (MS_TMR32_BASE +  0x100)
#define MS_TMR32_RIS_REG_ADDR           (MS_TMR32_BASE +  0x200)
#define MS_TMR32_MIS_REG_ADDR           (MS_TMR32_BASE +  0x204)
#define MS_TMR32_IM_REG_ADDR            (MS_TMR32_BASE +  0x208)
#define MS_TMR32_ICR_REG_ADDR           (MS_TMR32_BASE +  0x20C)

#define MS_TMR32_CTRL_EN                0x1
#define MS_TMR32_CTRL_TMR_EN            0x2
#define MS_TMR32_CTRL_PWM_EN            0x4
#define MS_TMR32_CTRL_COUNTER_EN        0x8
#define MS_TMR32_CTRL_CLK_SRC_CLK2      0x000
#define MS_TMR32_CTRL_CLK_SRC_CLK4      0x100
#define MS_TMR32_CTRL_CLK_SRC_CLK8      0x200
#define MS_TMR32_CTRL_CLK_SRC_CLK16     0x300
#define MS_TMR32_CTRL_CLK_SRC_CLK32     0x400
#define MS_TMR32_CTRL_CLK_SRC_CLK64     0x500
#define MS_TMR32_CTRL_CLK_SRC_CLK128    0x600
#define MS_TMR32_CTRL_CLK_SRC_CLK256    0x700
#define MS_TMR32_CTRL_CLK_SRC_CLK       0x800
#define MS_TMR32_CTRL_CLK_SRC_EXTCTR    0x900
#define MS_TMR32_CTRL_UP                0x10000
#define MS_TMR32_CTRL_ONE_SHOT          0x20000
#define MS_TMR32_CTRL_EVENT_POS         0x1000000
#define MS_TMR32_CTRL_EVENT_NEG         0x2000000
#define MS_TMR32_CTRL_EVENT_BOTH        0x3000000

volatile unsigned int * EF_TMR32_tmr_reg        = (volatile unsigned int *) (MS_TMR32_TMR_REG_ADDR    );
volatile unsigned int * EF_TMR32_period_reg     = (volatile unsigned int *) (MS_TMR32_PERIOD_REG_ADDR );
volatile unsigned int * EF_TMR32_pwmcmp_reg     = (volatile unsigned int *) (MS_TMR32_PWMCMP_REG_ADDR );
volatile unsigned int * EF_TMR32_match_reg      = (volatile unsigned int *) (MS_TMR32_MATCH_REG_ADDR  );
volatile unsigned int * EF_TMR32_counter_reg    = (volatile unsigned int *) (MS_TMR32_COUNTER_REG_ADDR);
volatile unsigned int * EF_TMR32_ctrl_reg       = (volatile unsigned int *) (MS_TMR32_CTRL_REG_ADDR   );
volatile unsigned int * EF_TMR32_ris_reg        = (volatile unsigned int *) (MS_TMR32_RIS_REG_ADDR    );
volatile unsigned int * EF_TMR32_mis_reg        = (volatile unsigned int *) (MS_TMR32_MIS_REG_ADDR    );
volatile unsigned int * EF_TMR32_im_reg         = (volatile unsigned int *) (MS_TMR32_IM_REG_ADDR     );
volatile unsigned int * EF_TMR32_icr_reg        = (volatile unsigned int *) (MS_TMR32_ICR_REG_ADDR    );
