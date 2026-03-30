module sync_fifo_tb;

    logic clk;
    logic rst_n;
    logic wr_en;
    logic rd_en;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic full;
    logic empty;

    sync_fifo dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        rst_n   = 1;
        wr_en   = 0;
        rd_en   = 0;
        data_in = 8'h00;

        #2;
        rst_n = 0;
        #10;
        rst_n = 1;
    end

endmodule
