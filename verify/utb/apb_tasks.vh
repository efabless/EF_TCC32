task apb_w_wr (input [31:0] address, input [31:0] data );
    begin
        @(posedge PCLK);
        PSEL = 1;
        PWRITE = 1;
        PWDATA = data;
        PENABLE = 0;
        PADDR = address;
        @(posedge PCLK);
        PENABLE = 1;
        @(posedge PCLK);
        PSEL = 0;
        PWRITE = 0;
        PENABLE = 0;
    end
endtask
		
task apb_w_rd(input [31:0] address, output [31:0] data );
    begin
        @(posedge PCLK);
        PSEL = 1;
        PWRITE = 0;
        PENABLE = 0;
        PADDR = address;
        @(posedge PCLK);
        PENABLE = 1;
        //@(posedge PREADY);
        wait(PREADY == 1)
        @(posedge PCLK) data = PRDATA;
        PSEL = 0;
        PWRITE = 0;
        PENABLE = 0;
    end
endtask 