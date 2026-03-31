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

        // ------------------------------------------------------------
        // Reset before TEST 4
        // Ensure TEST 4 starts from a clean state
        // ------------------------------------------------------------
        #2;
        rst_n = 0;
        #10;
        rst_n = 1;

        $display("Before TEST 4 (after reset): time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        // ------------------------------------------------------------
        // TEST 4: Full condition test
        // Goal:
        // Fill the FIFO completely and verify that full is asserted.
        // Then attempt one extra write and verify that the FIFO state
        // does not change.
        // Expected:
        // After 8 writes: count = 8, full = 1, empty = 0
        // After extra write: count and wr_ptr should not change
        // ------------------------------------------------------------
        data_in = 8'h01; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h02; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h03; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h04; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h05; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h06; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h07; wr_en = 1; #10; wr_en = 0;
        data_in = 8'h08; wr_en = 1; #10; wr_en = 0;

        $display("TEST 4 - After 8 writes: time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        if (full != 1'b1) begin
            $display("ERROR: Full condition test failed. FIFO should be full after 8 writes");
        end else begin
            $display("PASS: Full condition asserted correctly");
        end

        if (dut.count != 8) begin
            $display("ERROR: Full condition test failed. Expected count=8, got %0d", dut.count);
        end else begin
            $display("PASS: Count reached 8 correctly");
        end

        // Save state before illegal extra write
        // Expected: no change after this write attempt
        data_in = 8'hFF;
        wr_en   = 1;
        #10;
        wr_en   = 0;

        $display("TEST 4 - After extra write attempt: time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        if (dut.count != 8) begin
            $display("ERROR: Illegal write changed count");
        end else begin
            $display("PASS: Illegal write did not change count");
        end

        if (dut.wr_ptr != 0) begin
            $display("ERROR: Illegal write changed wr_ptr. Expected 0, got %0d", dut.wr_ptr);
        end else begin
            $display("PASS: Illegal write did not change wr_ptr");
        end

        // ------------------------------------------------------------
        // Reset before TEST 5
        // Ensure TEST 5 starts from a clean state
        // ------------------------------------------------------------
        #2;
        rst_n = 0;
        #10;
        rst_n = 1;

        $display("Before TEST 5 (after reset): time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        // ------------------------------------------------------------
        // TEST 5: Simultaneous read/write test
        // Goal:
        // Verify correct behavior when read and write happen
        // in the same cycle.
        // Expected:
        // - count should remain unchanged
        // - read should return the oldest value
        // - new written value should remain in the FIFO
        // ------------------------------------------------------------

        // Preload FIFO with two values: A1, B2
        data_in = 8'hA1; wr_en = 1; #10; wr_en = 0;
        data_in = 8'hB2; wr_en = 1; #10; wr_en = 0;

        $display("TEST 5 - Before simultaneous read/write: time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count);

        // Simultaneous read and write: read A1, write C3
        data_in = 8'hC3;
        wr_en   = 1;
        rd_en   = 1;
        #10;
        wr_en   = 0;
        rd_en   = 0;

        $display("TEST 5 - After simultaneous read/write: time=%0t | data_out=%0h wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, data_out, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        if (data_out != 8'hA1) begin
            $display("ERROR: Simultaneous read/write test failed. Expected read data A1, got %0h", data_out);
        end else begin
            $display("PASS: Simultaneous read returned the oldest value");
        end

        if (dut.count != 2) begin
            $display("ERROR: Simultaneous read/write test failed. Expected count=2, got %0d", dut.count);
        end else begin
            $display("PASS: Count remained unchanged during simultaneous read/write");
        end

        // Read next value -> expect B2
        rd_en = 1;
        #10;
        rd_en = 0;

        $display("TEST 5 - Read after simultaneous op (1): time=%0t | data_out=%0h", $time, data_out);
        if (data_out != 8'hB2) begin
            $display("ERROR: Expected B2, got %0h", data_out);
        end else begin
            $display("PASS: Next value after simultaneous op is correct (B2)");
        end

        // Read next value -> expect C3
        rd_en = 1;
        #10;
        rd_en = 0;

        $display("TEST 5 - Read after simultaneous op (2): time=%0t | data_out=%0h", $time, data_out);
        if (data_out != 8'hC3) begin
            $display("ERROR: Expected C3, got %0h", data_out);
        end else begin
            $display("PASS: Written value during simultaneous op remained in FIFO (C3)");
        end

        // ------------------------------------------------------------
        // Reset before TEST 6
        // Ensure TEST 6 starts from a clean state
        // ------------------------------------------------------------
        #2;
        rst_n = 0;
        #10;
        rst_n = 1;

        $display("Before TEST 6 (after reset): time=%0t | wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        // ------------------------------------------------------------
        // TEST 6: Empty / underflow test
        // Goal:
        // Attempt to read from an empty FIFO and verify that the state
        // does not change.
        // Expected:
        // - count remains 0
        // - rd_ptr does not change
        // - empty remains asserted
        // ------------------------------------------------------------
        rd_en = 1;
        #10;
        rd_en = 0;

        $display("TEST 6 - After empty read attempt: time=%0t | data_out=%0h wr_ptr=%0d rd_ptr=%0d count=%0d empty=%0b full=%0b",
                  $time, data_out, dut.wr_ptr, dut.rd_ptr, dut.count, empty, full);

        if (dut.count != 0) begin
            $display("ERROR: Empty read changed count. Expected 0, got %0d", dut.count);
        end else begin
            $display("PASS: Empty read did not change count");
        end

        if (dut.rd_ptr != 0) begin
            $display("ERROR: Empty read changed rd_ptr. Expected 0, got %0d", dut.rd_ptr);
        end else begin
            $display("PASS: Empty read did not change rd_ptr");
        end

        if (empty != 1'b1) begin
            $display("ERROR: Empty flag should remain asserted after empty read");
        end else begin
            $display("PASS: Empty flag remained asserted");
        end

        $finish;
    end


endmodule
