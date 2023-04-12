/*
    AMBA APB wrapper for the ms_tm32 Timer/Counter/Capture/PWM IP
    Author: Mohamed Shalan (mshalan@aucegypt.edu)
    License: MIT
*/
`timescale          1ns/1ns
`default_nettype    none

`define     APB_REG(name, init_value)    always @(posedge PCLK or negedge PRESETn) if(~PRESETn) name <= init_value; else if(apb_we & (PADDR==``name``_ADDR)) name <= PWDATA;

module ms_tmr32_apb (
    // APB Interface
    input  wire             PCLK,
    input  wire             PRESETn,
    input  wire  [31:0]     PADDR,
    input  wire             PWRITE,
    input  wire             PSEL,
    input  wire  [31:0]     PWDATA,
    output reg   [31:0]     PRDATA,
    output reg              PREADY,
    // IP External Interface
    input   wire            ctr_in,
    output  wire            pwm_out,
    // IRQ
    output  wire            irq
);
    localparam      TMR_REG_ADDR        =   32'h00,
                    PERIOD_REG_ADDR     =   32'h04,
                    PWMCMP_REG_ADDR     =   32'h08,
                    MATCH_REG_ADDR      =   32'h0C,
                    COUNTER_REG_ADDR    =   32'h10,
                    CTRL_REG_ADDR       =   32'h100,
                    RIS_REG_ADDR        =   32'h200,
                    MIS_REG_ADDR        =   32'h204,
                    IM_REG_ADDR         =   32'h208,
                    ICR_REG_ADDR        =   32'h20C;
                    
    // Wires to connect the IP instance
    wire [31:0] period;
    wire [31:0] pwm_cmp;
    wire [31:0] tmr;
    wire [31:0] cp_count;
    wire [31:0] ctr_match;
    wire [3:0]  clk_src;
    wire        to_flag;
    wire        tmr_en;
    wire        one_shot;
    wire        up;
    wire        pwm_en;
    wire        cp_en;
    wire  [1:0] cp_event;
    wire        cp_flag;
    wire        match_flag;
    wire        en;

    // The IP Instance
    ms_tmr32 ip (
		.clk(clk_i),
		.rst_n(~rst_i),
		.ctr_in(ctr_in),
		.pwm_out(pwm_out),
		.period(period),
		.pwm_cmp(pwm_cmp),
		.tmr(tmr),
		.to_flag(to_flag),
		.tmr_en(tmr_en),
		.one_shot(one_shot),
		.up(up),
		.pwm_en(pwm_en),
		.clk_src(clk_src),
		.cp_en(cp_en),
		.cp_event(cp_event),
		.cp_flag(cp_flag),
		.en(en),
		.cp_count(cp_count),
        .ctr_match(ctr_match),
        .match_flag(match_flag)
	);

    // R/W I/O Registers
    reg [31:0]  CTRL_REG;
    reg [31:0]  PERIOD_REG;
    reg [31:0]  PWMCMP_REG;
    reg [31:0]  MATCH_REG;
    reg [31:0]  IM_REG;
    reg [31:0]  ICR_REG;

    // This is a read only register 
    // but it has to be treated difgferently
    reg [31:0]  RIS_REG;

    // Read only I/O Registers
    wire[31:0]  COUNTER_REG = cp_count;
    wire[31:0]  TMR_REG     = tmr;
    wire[31:0]  MIS_REG     = RIS_REG & IM_REG;

    // Drive some of the wires
    assign  period      =   PERIOD_REG;
    assign  pwm_cmp     =   PWMCMP_REG;
    assign  ctr_match   =   MATCH_REG;
    assign  en          =   CTRL_REG[0:0];
    assign  tmr_en      =   CTRL_REG[1:1];
    assign  pwm_en      =   CTRL_REG[2:2];
    assign  cp_en       =   CTRL_REG[3:3];
    assign  clk_src     =   CTRL_REG[11:8];
    assign  up          =   CTRL_REG[16:16];
    assign  one_shot    =   CTRL_REG[17:17];
    assign  cp_event    =   CTRL_REG[25:24];
    
    // WB Control Signals
    wire        apb_valid        =   PSEL & PENABLE;
    wire        apb_we           =   PWRITE & apb_valid;
    wire        apb_re           =   ~PWRITE & apb_valid;
   
    // RIS Register
    // bit 0: Time-out Flag
    // bit 1: Capture Event Flag
    // bit 2: Counter MAtch Flag
    always @(posedge PCLK or negedge PRESETn)
        if(~PRESETn)   
            RIS_REG <= 32'd0;
        else begin
            if(to_flag)    
                RIS_REG[0] <= 1'b1;
            else if(ICR_REG[0])
                RIS_REG[0] <= 1'b0;
            
            if(cp_flag)    
                RIS_REG[1] <= 1'b1;
            else if(ICR_REG[1])
                RIS_REG[1] <= 1'b0;
            
            if(match_flag)    
                RIS_REG[2] <= 1'b1;
            else if(ICR_REG[2])
                RIS_REG[2] <= 1'b0;

        end

    // ICR Register
    // Writing to it clears the corresponding Interrupt flag
    // Automatically clears to 0 after writing to it
    always @(posedge PCLK or negedge PRESETn)
        if(~PRESETn)
            ICR_REG <= 32'b0;
        else
            if(apb_we & (PADDR_i==ICR_REG_ADDR))
                ICR_REG <= PWDATA;
            else
                ICR_REG <= 32'd0;

    `APB_REG(CTRL_REG, 32'd0)
    `APB_REG(MATCH_REG, 32'd0)
    `APB_REG(PWMCMP_REG, 32'd0)
    `APB_REG(PERIOD_REG, 32'd0)
    `APB_REG(IM_REG, 32'd0)

    // WB Data out
    assign  PRDATA  =   (PADDR == TMR_REG_ADDR)     ?   TMR_REG     :
                        (PADDR == PERIOD_REG_ADDR)  ?   PERIOD_REG  :
                        (PADDR == PWMCMP_REG_ADDR)  ?   PWMCMP_REG  :
                        (PADDR == MATCH_REG_ADDR)   ?   MATCH_REG   :
                        (PADDR == COUNTER_REG_ADDR) ?   PERIOD_REG  :
                        (PADDR == CTRL_REG_ADDR)    ?   CTRL_REG    :
                        (PADDR == RIS_REG_ADDR)     ?   RIS_REG     :
                        (PADDR == MIS_REG_ADDR)     ?   MIS_REG     :
                        (PADDR == IM_REG_ADDR)      ?   IM_REG      :
                        (PADDR == ICR_REG_ADDR)     ?   32'd0       :   32'hDEADBEEF;
                 
    assign irq = |MIS_REG;

    assign PREADY = 1'b1;

endmodule