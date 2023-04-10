// file: ms_tmr32_tb.v
// author: mshalan@aucegypt.edu
// Testbench for TMR

`timescale 1ns/1ns

module TMR_tb;
	// Declarations
	reg         clk;
	reg         rst_n;
	reg         ctr_in;
	wire        pwm_out;
	reg  [31:0] period;
	reg  [31:0] pwm_cmp;
	wire [31:0] tmr;
	wire [31:0] cp_count;
    reg  [31:0] ctr_match;
	reg   [3:0] clk_src;
	wire        to_flag;
	reg         tmr_en;
	reg         one_shot;
	reg         up;
	reg         pwm_en;
	reg         cp_en;
	reg   [1:0] cp_event;
	wire        cp_flag;
    wire        match_flag;
	reg         en;
	
	
	reg[3:0]    Test;

	// Instantiation of Unit Under Test
	ms_tmr32 muv (
		.clk(clk),
		.rst_n(rst_n),
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

    initial begin
        $dumpfile("ms_tmr32_tb.vcd");
        $dumpvars;
    end

	initial begin
		// Input Initialization
		clk         = 0;
		rst_n       = 0;
		ctr_in      = 0;
		period      = 0;
		pwm_cmp     = 0;
		tmr_en      = 0;
		one_shot    = 0;
		up          = 0;
		pwm_en      = 0;
		clk_src     = 1;
		cp_en       = 0;
		cp_event    = 1;
		en          = 0;
		
		// Deassert rst_n
		#1000;
		@(posedge clk);
		rst_n = 1;
		
		// Enable the timer
		@(posedge clk);
		en = 1;
		
		// Test 1
		// configure the timer: one shot, down, period = 20
		// Run till it times out then disable it
		Test = 1;
		@(posedge clk);
		period = 20;
		@(posedge clk);
		up = 0;
		@(posedge clk);
		one_shot = 1;
		@(posedge clk);
		tmr_en = 1;
		@(negedge to_flag);
		@(posedge clk);
		tmr_en = 0;
        if(tmr == 20)
            $display("Test 1 passed.");
        else
            $display("Test 1 failed.");

        // Test 2
        // configure the timer: periodic, up, period = 10
		// Run till it times out then disable it
		Test = 2;
        @(posedge clk);
		period = 10;
		@(posedge clk);
		up = 1;
		@(posedge clk);
		one_shot = 0;
		@(posedge clk);
        tmr_en = 1;
        @(negedge to_flag);
		@(posedge clk);
        @(negedge to_flag);
		@(posedge clk);
		tmr_en = 0;
        if(tmr == 0)
            $display("Test 2 passed.");
        else
            $display("Test 2 failed.");

		
		// Test 3
		// PWM output with Test 2 configurations
		// PWM CMP is 5
		Test = 3;
		@(posedge clk);
		pwm_cmp = 5;
		@(posedge clk);
		pwm_en = 1;
		tmr_en = 1;
		@(negedge pwm_out);
		@(negedge pwm_out);
		@(posedge clk);
		tmr_en = 0;
		
		
		// Test 4
		// Measure the time between external events
		Test = 4;
		@(posedge clk);
		cp_event = 1;
		@(posedge clk);
		cp_en = 1;
		@(negedge cp_flag);
		#50;
        @(posedge clk);
		cp_event = 2;
		@(negedge cp_flag);
		#50;
        @(posedge clk);
		cp_event = 3;
		@(negedge cp_flag);
		#50;
        @(posedge clk);
        cp_en = 0;
        #100;

        // Test 5
        // Counter and Match
        Test = 5;
        @(posedge clk);
        ctr_match = 17;
        clk_src = 9;
        up = 1;
        period = 30;
        @(posedge clk);
        tmr_en = 1;
        @(negedge match_flag);    
        en = 0;
		
		@(posedge clk);
		#100;
        $finish;
		
	end
	
	always #50 clk <= ~clk;
	
	always #939 ctr_in <= ~ctr_in;
	

endmodule