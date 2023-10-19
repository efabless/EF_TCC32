/*
    Testbench for the WB wrapper for the EF_TMR32 IP (EF_TMR32_wb)
    Author: Mohamed Shalan (mshalan@aucegypt.edu)
    License: MIT
*/

`timescale 1ns/1ns

module EF_TMR32_wb_tb;

    `include "params.vh"
    `include "apb_tasks.vh"

    localparam CLK_PERIOD = 40;
    localparam TIMEOUT = 1000_000;

    reg         ctr_in;

    reg  		PCLK;
	reg  		PRESETn;
	reg  [31:0]	PADDR;
	reg  		PWRITE;
	reg  		PSEL;
	reg  		PENABLE;
	reg  [31:0]	PWDATA;
	wire [31:0]	PRDATA;
	wire 		PREADY;
	wire 		irq;
    wire        ext_clk = ctr_in;

    EF_TCC32_apb MUV (
	    .ext_clk(ext_clk),
	    .PCLK(PCLK),
	    .PRESETn(PRESETn),
	    .PADDR(PADDR),
	    .PWRITE(PWRITE),
	    .PSEL(PSEL),
	    .PENABLE(PENABLE),
	    .PWDATA(PWDATA),
	    .PRDATA(PRDATA),
	    .PREADY(PREADY),
	    .irq(irq)
    );

    // Dump the signals
    initial begin
        $dumpfile("EF_TCC32_apb_tb.vcd");
        $dumpvars(0, MUV);
    end

    // Stop the simulation after 1ms (Tiemout)
    initial begin
        #TIMEOUT;
        $display("Failed: Timeout");
        $finish; 
    end

    // clock and rest generator
    event power_on, reset_done;
    initial begin
        PCLK <= 1'bx;
        PRESETn <= 1'bx;
        // Power ON
        #25;
        -> power_on;
        PSEL <= 0;
        PENABLE <= 0;
    end

    always #(CLK_PERIOD/2) PCLK <= ~PCLK;

    initial begin
        @(power_on);
        PRESETn <= 1'b0;
        PCLK <= 1'b0;
        #999;
        @(posedge PCLK);
        PRESETn <= 1'b1;
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
        apb_w_wr(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer
        apb_w_wr(ICR_REG_ADDR, INT_TO_FLAG|INT_MATCH_FLAG|INT_CP_FLAG);
        // Down Counter, One Shot, Timer is Enabled and IP is enabled
        apb_w_wr(CONTROL_REG_ADDR, CTRL_EN|CTRL_TMR_EN|CTRL_MODE_ONESHOT);
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
        apb_w_wr(CONTROL_REG_ADDR, 32'h0);
        // Period = 20
        apb_w_wr(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer
        apb_w_wr(ICR_REG_ADDR, 32'h7);
        // Down Counter, Periodic, Timer is Enabled and IP is enabled
        apb_w_wr(CONTROL_REG_ADDR, 32'h0000_0003);
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
        apb_w_wr(CONTROL_REG_ADDR, 32'h0);
        // Period = 20
        apb_w_wr(PERIOD_REG_ADDR, 32'd20);
        // Clear all flags before enabling the Timer (write to ICR)
        apb_w_wr(ICR_REG_ADDR, 32'h7);
        // Enable TO IRQ by writing to the IM Register
        apb_w_wr(IM_REG_ADDR, 32'h1);
        // Down Counter, Periodic, Timer is Enabled and IP is enabled
        apb_w_wr(CONTROL_REG_ADDR, 32'h0000_0003);
        // Wait for the irq to fire
        @(posedge irq);
        // Clear all the flags
        apb_w_wr(ICR_REG_ADDR, 32'h7);
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
        apb_w_wr(CONTROL_REG_ADDR, 32'h0);
        // Clear all flags before enabling the Timer (write to ICR)
        apb_w_wr(ICR_REG_ADDR, 32'h7);
        // Enable Capture IRQ
        apb_w_wr(IM_REG_ADDR, 32'h2);
        // Up counting, 
        apb_w_wr(CONTROL_REG_ADDR, CTRL_EN|CTRL_TMR_EN|CTRL_CP_EN|CTRL_COUNT_UP|CTRL_CPEVENT_PE);
        // Wait for the irq to fire
        @(posedge irq);
        // Check the irq source
        apb_w_rd(MIS_REG_ADDR, data_out);
        if(data_out & 2) 
            $display("Test 4: Passed");
        else begin
            $display("Test 4: Failed");
            $finish;
        end
        // Clear all the flags
        apb_w_wr(ICR_REG_ADDR, 32'h7);
        #1000;
        -> test4_done;
    end

    // Test 5
    // External Events Capture
    initial begin
        @(test4_done);
        // Disable the timer before reconfiguring it.
        apb_w_wr(CONTROL_REG_ADDR, 32'h0);
        // Clear all flags before enabling the Timer (write to ICR)
        apb_w_wr(ICR_REG_ADDR, 32'h7);
        // Enable Counter Match IRQ
        apb_w_wr(IM_REG_ADDR, INT_MATCH_FLAG);
        // Write to the counter match register 5
        apb_w_wr(COUNTER_MATCH_REG_ADDR, 32'h5);
        // Up counting, Count external events
        apb_w_wr(CONTROL_REG_ADDR, CTRL_EN|CTRL_TMR_EN|CTRL_COUNT_UP|CTRL_CLKSRC_EXT);
        // Wait for the match irq to fire
        @(posedge irq);
        // Check the irq source
        apb_w_rd(MIS_REG_ADDR, data_out);
        if(data_out & 4) 
            $display("Test 5: Passed");
        else begin
            $display("Test 5: Failed");
            $finish;
        end
        // Clear all the flags
        apb_w_wr(ICR_REG_ADDR, 32'h7);
        // Disable the timer
        apb_w_wr(CONTROL_REG_ADDR, 0);
        #1000;
        $display("All tests have passed!");
        $finish;
    end




task tmr_wait_to;
    begin: task_body
        reg [31:0] ris;
        ris = 0;
        while(ris == 0) begin
            apb_w_rd(RIS_REG_ADDR, ris);
        end 
    end
endtask

endmodule