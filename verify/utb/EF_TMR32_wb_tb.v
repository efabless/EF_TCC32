/*
    Testbench for the WB wrapper for the EF_TMR32 IP (EF_TMR32_wb)
    Author: Mohamed Shalan (mshalan@aucegypt.edu)
    License: MIT
*/

`timescale 1ns/1ns

module EF_TMR32_wb_tb;

    localparam 
        TMR_REG_ADDR        =   32'h00,
        PERIOD_REG_ADDR     =   32'h04,
        PWMCMP_REG_ADDR     =   32'h08,
        MATCH_REG_ADDR      =   32'h0C,
        COUNTER_REG_ADDR    =   32'h10,
        CTRL_REG_ADDR       =   32'h100,
        RIS_REG_ADDR        =   32'h200,
        MIS_REG_ADDR        =   32'h204,
        IM_REG_ADDR         =   32'h208,
        ICR_REG_ADDR        =   32'h20C;

    localparam  
        CTRL_EN             = 1,
        CTRL_TMR_EN         = 2,
        CTRL_PWM_EN         = 4,
        CTRL_COUNTER_EN     = 8,
        CTRL_CLK_SRC_CLK2   = 32'h000,
        CTRL_CLK_SRC_CLK4   = 32'h100,
        CTRL_CLK_SRC_CLK8   = 32'h200,
        CTRL_CLK_SRC_CLK16  = 32'h300,
        CTRL_CLK_SRC_CLK32  = 32'h400,
        CTRL_CLK_SRC_CLK64  = 32'h500,
        CTRL_CLK_SRC_CLK128 = 32'h600,
        CTRL_CLK_SRC_CLK256 = 32'h700,
        CTRL_CLK_SRC_CLK    = 32'h800,
        CTRL_CLK_SRC_EXTCTR = 32'h900,
        CTRL_UP             = 32'h1_0000,
        CTRL_ONE_SHOT       = 32'h2_0000,
        CTRL_EVENT_POS      = 32'h100_0000,
        CTRL_EVENT_NEG      = 32'h200_0000,
        CTRL_EVENT_BOTH     = 32'h300_0000;
        

    reg         clk_i;
    reg         rst_i;
    reg [31:0]  adr_i;
    reg [31:0]  dat_i;
    wire[31:0]  dat_o;
    reg [3:0]   sel_i;
    reg         cyc_i;
    reg         stb_i;
    wire        ack_o;
    reg         we_i;
    reg         ctr_in;
    wire        pwm_out;
    wire        irq;

    EF_TMR32_wb muv (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .adr_i(adr_i),
        .dat_i(dat_i),
        .dat_o(dat_o),
        .sel_i(sel_i),
        .cyc_i(cyc_i),
        .stb_i(stb_i),
        .ack_o(ack_o),
        .we_i(we_i),
        .ctr_in(ctr_in),
        .pwm_out(pwm_out),
        .irq(irq)
    );

    // Dump the signals
    initial begin
        $dumpfile("EF_TMR32_wb_tb.vcd");
        $dumpvars;
    end

    // Stop the simulation after 1ms (Tiemout)
    initial begin
        #1000_000;
        $display("Failed: Timeout");
        $finish; 
    end

    // clock and rest generator
    localparam CLK_PERIOD = 40;
    event power_on, reset_done;
    initial begin
        clk_i <= 1'bx;
        rst_i <= 1'bx;
        // Power ON
        #25;
        -> power_on;
        cyc_i <= 0;
        stb_i <= 0;
    end

    always #(CLK_PERIOD/2) clk_i <= ~clk_i;

    initial begin
        @(power_on);
        rst_i <= 1'b1;
        clk_i <= 1'b0;
        #999;
        @(posedge clk_i);
        rst_i <= 1'b0;
        -> reset_done;
    end

    // External Events
    event extern_ctr_start;
    initial begin
        ctr_in = 0;
        @(extern_ctr_start);
        repeat(50)
            #(CLK_PERIOD*17.3/2) ctr_in = !ctr_in;
    end


    // Test Cases
    reg [31:0] data_out;
    // Test case 1
    // Timer time-out, one shot
    event test1_done, test2_done, test3_done, test4_done, test5_done;
    initial begin
        @(reset_done);
        // Period = 4
        wb_master_word_wr(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        // Down Counter, One Shot, Timer is Enabled and IP is enabled
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0002_0003);
        tmr_wait_to();
        $display("Test 1: Passed");
        #1000;
        -> test1_done;
    end
    
    // Test 2
    // Timer time-out, periodic
    initial begin
        @(test1_done);
        // Disable the timer before reconfiguring it.
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0);
        // Period = 20
        wb_master_word_wr(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        // Down Counter, Periodic, Timer is Enabled and IP is enabled
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0000_0003);
        tmr_wait_to();
        tmr_wait_to();
        tmr_wait_to();
        $display("Test 2: Passed");
        #1000;
        -> test2_done;
    end

    // Test 3
    // Timer time-out IRQ, periodic
    initial begin
        @(test2_done);
        // Disable the timer before reconfiguring it.
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0);
        // Period = 20
        wb_master_word_wr(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer (write to ICR)
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        // Enable TO IRQ by writing to the IM Register
        wb_master_word_wr(IM_REG_ADDR, 32'h1);
        // Down Counter, Periodic, Timer is Enabled and IP is enabled
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0000_0003);
        // Wait for the irq to fire
        @(posedge irq);
        // Clear all the flags
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        $display("Test 3: Passed");
        #1000;
        -> test3_done;
    end

    // Test 4
    // PMW Generation
    initial begin
        @(test3_done);
        // Disable the timer before reconfiguring it.
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0);
        // Period = 20
        wb_master_word_wr(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer (write to ICR)
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        // Disable Inetrrupts writing to the IM Register
        wb_master_word_wr(IM_REG_ADDR, 32'h0);
        // Set the PWM Compare Register to 10 (50% duty cycle)
        wb_master_word_wr(PWMCMP_REG_ADDR, 32'd10);
        // Down Counter, Periodic, Timer is Enabled, PWM is enabled and IP is enabled
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0000_0007);
        // Wait for the irq to fire
        @(posedge pwm_out);
        @(posedge pwm_out);
        // Clear all the flags
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        
        $display("Test 4: Passed");
        #1000;
        -> test4_done;
    end
    

    // Test 5
    // External Events Capture
    initial begin
        @(test4_done);
        -> extern_ctr_start;
        // Disable the timer before reconfiguring it.
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0);
        // Clear all flags before enabling the Timer (write to ICR)
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        // Enable Capture IRQ
        wb_master_word_wr(IM_REG_ADDR, 32'h2);
        // Up counting, 
        wb_master_word_wr(CTRL_REG_ADDR, CTRL_EN|CTRL_COUNTER_EN|CTRL_UP|CTRL_EVENT_POS);
        // Wait for the irq to fire
        @(posedge irq);
        // Check the irq source
        wb_master_word_rd(MIS_REG_ADDR, data_out);
        if(data_out & 2) 
            $display("Test 5: Passed");
        else begin
            $display("Test 5: Failed");
            $finish;
        end
        // Clear all the flags
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        #1000;
        -> test5_done;
    end

    // Test 6
    // External Events Capture
    initial begin
        @(test5_done);
        // Disable the timer before reconfiguring it.
        wb_master_word_wr(CTRL_REG_ADDR, 32'h0);
        // Clear all flags before enabling the Timer (write to ICR)
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        // Enable Counter Match IRQ
        wb_master_word_wr(IM_REG_ADDR, 32'h4);
        // Write to the counter match register 5
        wb_master_word_wr(MATCH_REG_ADDR, 32'h5);
        // Up counting, Count external events
        wb_master_word_wr(CTRL_REG_ADDR, CTRL_EN|CTRL_TMR_EN|CTRL_UP|CTRL_CLK_SRC_EXTCTR);
        // Wait for the match irq to fire
        @(posedge irq);
        // Check the irq source
        wb_master_word_rd(MIS_REG_ADDR, data_out);
        if(data_out & 4) 
            $display("Test 6: Passed");
        else begin
            $display("Test 6: Failed");
            $finish;
        end
        // Clear all the flags
        wb_master_word_wr(ICR_REG_ADDR, 32'h7);
        // Disable the timer
        wb_master_word_wr(CTRL_REG_ADDR, 0);
        #1000;
        $display("All tests have passed!");
        $finish;
    end




task tmr_wait_to;
    begin: task_body
        reg [31:0] ris;
        ris = 0;
        while(ris == 0) begin
            wb_master_word_rd(RIS_REG_ADDR, ris);
        end 
    end
endtask

task wb_master_word_wr(input [31:0] addr, input [31:0] data);
    begin : task_body
        @(posedge clk_i);
        #1;
        cyc_i <= 1;
        stb_i <= 1;
        we_i <= 1;
        adr_i <= addr;
        dat_i <= data;
        sel_i <= 4'hF;
        @(posedge ack_o);
        @(posedge clk_i);
        cyc_i <= 0;
        stb_i <= 0;
    end
endtask

task wb_master_word_rd(input [31:0] addr, output [31:0] data);
    begin : task_body
        @(posedge clk_i);
        #1;
        cyc_i <= 1;
        stb_i <= 1;
        we_i <= 0;
        adr_i <= addr;
        dat_i <= 0;
        sel_i <= 4'hF;
        @(posedge ack_o);
        @(posedge clk_i);
        data = dat_o;
        cyc_i = 0;
        stb_i = 0;
    end
endtask

endmodule