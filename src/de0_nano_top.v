module de0_nano_top (
    input  wire       CLOCK_50,
    input  wire       KEY0,       // reset, active low
    input  wire       KEY1,       // trigger, active low
    output wire [7:0] LED,
    output wire       GPIO_0_0,   // TX
    input  wire       GPIO_0_1    // RX
);

wire tx_busy;
wire tx;
wire rx_done;
wire [7:0] rx_data;

reg tx_start;
reg [7:0] tx_data;
reg [2:0] test_index;

// for simple button edge detect
reg key1_prev;

// UART instance
uart_transceiver uart (
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy),
    .tx(tx),
    .rx(GPIO_0_1),
    .rx_done(rx_done),
    .rx_data(rx_data)
);

// clock/reset aliases
wire clk   = CLOCK_50;
wire rst_n = KEY0;

// TX output pin
assign GPIO_0_0 = tx;

// Show received data on LEDs
assign LED = rx_data;

// Button-controlled test pattern sender
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_start   <= 1'b0;
        tx_data    <= 8'h00;
        test_index <= 3'd0;
        key1_prev  <= 1'b1;
    end else begin
        tx_start <= 1'b0;   // default: pulse for one clock only

        // save previous button state
        key1_prev <= KEY1;

        // detect button press: KEY1 goes from 1 to 0
        if ((key1_prev == 1'b1) && (KEY1 == 1'b0) && !tx_busy) begin

            case (test_index)
                3'd0: tx_data <= 8'hB4;
                3'd1: tx_data <= 8'h10;
                3'd2: tx_data <= 8'h9C;
                3'd3: tx_data <= 8'h59;
                3'd4: tx_data <= 8'h00;
                3'd5: tx_data <= 8'hFF;
                default: tx_data <= 8'hB4;
            endcase

            tx_start <= 1'b1;

            if (test_index == 3'd5)
                test_index <= 3'd0;
            else
                test_index <= test_index + 1'b1;
        end
    end
end

endmodule