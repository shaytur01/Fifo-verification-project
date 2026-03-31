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

    // Clock generation: toggle clock every 5 time units
    always #5 clk = ~clk;

    initial begin
        // ------------------------------------------------------------
        // Initial signal setup
        // ------------------------------------------------------------
        clk     = 0;
        rst_n   = 1;
        wr_en   = 0;
        rd_en   = 0;
        data_in = 8'h00;

        // ------------------------------------------------------------
        // TEST 1: Reset test
        // Goal:
        // Verify that reset initializes the FIFO correctly.
        // Expected:
        // wr_ptr = 0, rd_ptr = 0, count = 0, empty = 1, full = 0
        // ------------------------------------------------------------
        #2;
        rst_n = 0;
        #10;
        rst_n = 1;

        $display("TEST 1 - After reset: time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        if (dut.wr_ptr != 0 || dut.rd_ptr != 0 || dut.count != 0 || empty != 1'b1 || full != 1'b0) begin
            $display("ERROR: Reset test failed");
        end else begin
            $display("PASS: Reset test passed");
        end

        // ------------------------------------------------------------
        // TEST 2: Single write and single read test
        // Goal:
        // Write one value into the FIFO and read it back.
        // Expected:
        // Written value = Read value
        // ------------------------------------------------------------
        data_in = 8'hAA;
        wr_en   = 1;
        #10;
        wr_en   = 0;

        $display("TEST 2 - After write: time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        rd_en = 1;
        #10;
        rd_en = 0;

        $display("TEST 2 - After read: time=%0t | data_out=%0h wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, data_out, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        if (data_out != 8'hAA) begin
            $display("ERROR: Single write/read test failed. Expected AA, got %0h", data_out);
        end else begin
            $display("PASS: Single write/read test passed");
        end

        // ------------------------------------------------------------
        // TEST 3: FIFO order test
        // Goal:
        // Write multiple values and verify that they are read
        // in the same order they were written.
        // Expected read order:
        // 11 -> 22 -> 33
        // ------------------------------------------------------------
        data_in = 8'h11; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h22; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h33; wr_en = 1; #10; wr_en = 0;

        $display("TEST 3 - After 3 writes: time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        rd_en = 1; #10; rd_en = 0;
        $display("TEST 3 - Read 1: time=%0t | data_out=%0h", $time, data_out);
        if (data_out != 8'h11) begin
            $display("ERROR: FIFO order test failed at read 1. Expected 11, got %0h", data_out);
        end else begin
            $display("PASS: FIFO order test read 1 passed");
        end

        rd_en = 1; #10; rd_en = 0;
        $display("TEST 3 - Read 2: time=%0t | data_out=%0h", $time, data_out);
        if (data_out != 8'h22) begin
            $display("ERROR: FIFO order test failed at read 2. Expected 22, got %0h", data_out);
        end else begin
            $display("PASS: FIFO order test read 2 passed");
        end

        rd_en = 1; #10; rd_en = 0;
        $display("TEST 3 - Read 3: time=%0t | data_out=%0h", $time, data_out);
        if (data_out != 8'h33) begin
            $display("ERROR: FIFO order test failed at read 3. Expected 33, got %0h", data_out);
        end else begin
            $display("PASS: FIFO order test read 3 passed");
        end

        $display("TEST 3 - Final state: time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        $finish;
    end

endmodule
