initial begin
    rst_n = 0;
    tx_start = 0;
    tx_data = 0;

    #100;
    rst_n = 1;
    #100;

    // TEST 1
    $display("Starting TEST 1");
    tx_data = 8'd180;
    tx_start = 1;
    #20;
    tx_start = 0;
    wait(rx_done);
    $display("Finished TEST 1, rx_data = %h", rx_data);

    #200;

    // TEST 2
    $display("Starting TEST 2");
    tx_data = 8'd16;
    tx_start = 1;
    #20;
    tx_start = 0;
    wait(rx_done);
    $display("Finished TEST 2, rx_data = %h", rx_data);

    #200;

    // TEST 3
    $display("Starting TEST 3");
    tx_data = 8'd156;
    tx_start = 1;
    #20;
    tx_start = 0;
    wait(rx_done);
    $display("Finished TEST 3, rx_data = %h", rx_data);

    #200;

    // TEST 4
    $display("Starting TEST 4");
    tx_data = 8'd89;
    tx_start = 1;
    #20;
    tx_start = 0;
    wait(rx_done);
    $display("Finished TEST 4, rx_data = %h", rx_data);

    #200;

    // TEST 5
    $display("Starting TEST 5");
    tx_data = 8'd0;
    tx_start = 1;
    #20;
    tx_start = 0;
    wait(rx_done);
    $display("Finished TEST 5, rx_data = %h", rx_data);

    #200;

    // TEST 6
    $display("Starting TEST 6");
    tx_data = 8'd255;
    tx_start = 1;
    #20;
    tx_start = 0;
    wait(rx_done);
    $display("Finished TEST 6, rx_data = %h", rx_data);

    #1000;
    $stop;
end