/*
    Testbench for the WB wrapper for the EF_TMR32 IP (EF_TMR32_wb)
    Author: Mohamed Shalan (mshalan@aucegypt.edu)
    License: MIT
*/

`timescale 1ns/1ns

module EF_TMR32_wb_tb;

    `include "params.vh"
    `include "wb_tasks.vh"

    localparam CLK_PERIOD = 40;

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
    wire        ext_clk = ctr_in;

    EF_TCC32_wb muv (
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
        .ext_clk(ext_clk),
        //.pwm_out(pwm_out),
        .irq(irq)
    );

    // Dump the signals
    initial begin
        $dumpfile("EF_TCC32_wb_tb.vcd");
        $dumpvars;
    end

    // Stop the simulation after 1ms (Tiemout)
    initial begin
        #1000_000;
        $display("Failed: Timeout");
        $finish; 
    end

    // clock and rest generator
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
    event extern_clk_start;
    initial begin
        ctr_in = 0;
        @(extern_clk_start);
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
        // Period = 20
        WB_M_WR_W(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer
        WB_M_WR_W(ICR_REG_ADDR, INT_TO_FLAG|INT_MATCH_FLAG|INT_CP_FLAG);
        // Down Counter, One Shot, Timer is Enabled and IP is enabled
        WB_M_WR_W(CONTROL_REG_ADDR, CTRL_EN|CTRL_TMR_EN|CTRL_MODE_ONESHOT);
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
        WB_M_WR_W(CONTROL_REG_ADDR, 32'h0);
        // Period = 20
        WB_M_WR_W(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer
        WB_M_WR_W(ICR_REG_ADDR, 32'h7);
        // Down Counter, Periodic, Timer is Enabled and IP is enabled
        WB_M_WR_W(CONTROL_REG_ADDR, 32'h0000_0003);
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
        WB_M_WR_W(CONTROL_REG_ADDR, 32'h0);
        // Period = 20
        WB_M_WR_W(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer (write to ICR)
        WB_M_WR_W(ICR_REG_ADDR, 32'h7);
        // Enable TO IRQ by writing to the IM Register
        WB_M_WR_W(IM_REG_ADDR, 32'h1);
        // Down Counter, Periodic, Timer is Enabled and IP is enabled
        WB_M_WR_W(CONTROL_REG_ADDR, 32'h0000_0003);
        // Wait for the irq to fire
        @(posedge irq);
        // Clear all the flags
        WB_M_WR_W(ICR_REG_ADDR, 32'h7);
        $display("Test 3: Passed");
        #1000;
        -> test3_done;
    end

    
    // Test 4
    // External Events Capture
    initial begin
        @(test3_done);
        -> extern_clk_start;
        // Disable the timer before reconfiguring it.
        WB_M_WR_W(CONTROL_REG_ADDR, 32'h0);
        // Clear all flags before enabling the Timer (write to ICR)
        WB_M_WR_W(ICR_REG_ADDR, 32'h7);
        // Enable Capture IRQ
        WB_M_WR_W(IM_REG_ADDR, 32'h2);
        // Up counting, 
        WB_M_WR_W(CONTROL_REG_ADDR, CTRL_EN|CTRL_TMR_EN|CTRL_CP_EN|CTRL_COUNT_UP|CTRL_CPEVENT_PE);
        // Wait for the irq to fire
        @(posedge irq);
        // Check the irq source
        WB_M_RD_W(MIS_REG_ADDR, data_out);
        if(data_out & 2) 
            $display("Test 4: Passed");
        else begin
            $display("Test 4: Failed");
            $finish;
        end
        // Clear all the flags
        WB_M_WR_W(ICR_REG_ADDR, 32'h7);
        #1000;
        -> test4_done;
    end

    // Test 5
    // External Events Capture
    initial begin
        @(test4_done);
        // Disable the timer before reconfiguring it.
        WB_M_WR_W(CONTROL_REG_ADDR, 32'h0);
        // Clear all flags before enabling the Timer (write to ICR)
        WB_M_WR_W(ICR_REG_ADDR, 32'h7);
        // Enable Counter Match IRQ
        WB_M_WR_W(IM_REG_ADDR, INT_MATCH_FLAG);
        // Write to the counter match register 5
        WB_M_WR_W(COUNTER_MATCH_REG_ADDR, 32'h5);
        // Up counting, Count external events
        WB_M_WR_W(CONTROL_REG_ADDR, CTRL_EN|CTRL_TMR_EN|CTRL_COUNT_UP|CTRL_CLKSRC_EXT);
        // Wait for the match irq to fire
        @(posedge irq);
        // Check the irq source
        WB_M_RD_W(MIS_REG_ADDR, data_out);
        if(data_out & 4) 
            $display("Test 5: Passed");
        else begin
            $display("Test 5: Failed");
            $finish;
        end
        // Clear all the flags
        WB_M_WR_W(ICR_REG_ADDR, 32'h7);
        // Disable the timer
        WB_M_WR_W(CONTROL_REG_ADDR, 0);
        #1000;
        $display("All tests have passed!");
        $finish;
    end




task tmr_wait_to;
    begin: task_body
        reg [31:0] ris;
        ris = 0;
        while(ris == 0) begin
            WB_M_RD_W(RIS_REG_ADDR, ris);
        end 
    end
endtask
/*
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
*/
endmodule