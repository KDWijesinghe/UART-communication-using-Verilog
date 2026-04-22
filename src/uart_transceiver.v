module uart_transceiver (
    input wire clk,
    input wire rst_n,

    // UART TX Interface
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx_busy,
    output reg tx,

    // UART RX Interface
    input wire rx,
    output reg rx_done,
    output reg [7:0] rx_data
);

parameter CLK_FREQ = 50000000;
parameter BAUD_RATE = 115200;
parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

// TX registers
reg [1:0] tx_state;
reg [15:0] tx_clk_count;
reg [2:0] tx_bit_count;
reg [7:0] tx_shift_reg;

// RX registers
reg [1:0] rx_state;
reg [15:0] rx_clk_count;
reg [2:0] rx_bit_count;
reg [7:0] rx_shift_reg;
reg rx_d1, rx_d2;

// Synchronize RX input
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_d1 <= 1'b1;
        rx_d2 <= 1'b1;
    end else begin
        rx_d1 <= rx;
        rx_d2 <= rx_d1;
    end
end

// ================= TX =================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_state <= IDLE;
        tx_clk_count <= 0;
        tx_bit_count <= 0;
        tx_busy <= 0;
        tx <= 1'b1;
        tx_shift_reg <= 8'h00;
    end else begin
        case (tx_state)

            IDLE: begin
                tx <= 1'b1;
                tx_clk_count <= 0;
                tx_bit_count <= 0;

                if (tx_start && !tx_busy) begin
                    tx_busy <= 1'b1;
                    tx_shift_reg <= tx_data;
                    tx_state <= START;
                end
            end

            START: begin
                tx <= 1'b0;

                if (tx_clk_count < CLKS_PER_BIT - 1)
                    tx_clk_count <= tx_clk_count + 1'b1;
                else begin
                    tx_clk_count <= 0;
                    tx_state <= DATA;
                end
            end

            DATA: begin
                tx <= tx_shift_reg[0];

                if (tx_clk_count < CLKS_PER_BIT - 1)
                    tx_clk_count <= tx_clk_count + 1'b1;
                else begin
                    tx_clk_count <= 0;
                    tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};

                    if (tx_bit_count < 7)
                        tx_bit_count <= tx_bit_count + 1'b1;
                    else begin
                        tx_bit_count <= 0;
                        tx_state <= STOP;
                    end
                end
            end

            STOP: begin
                tx <= 1'b1;

                if (tx_clk_count < CLKS_PER_BIT - 1)
                    tx_clk_count <= tx_clk_count + 1'b1;
                else begin
                    tx_clk_count <= 0;
                    tx_busy <= 1'b0;
                    tx_state <= IDLE;
                end
            end

            default: tx_state <= IDLE;
        endcase
    end
end

// ================= RX =================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_state <= IDLE;
        rx_clk_count <= 0;
        rx_bit_count <= 0;
        rx_done <= 0;
        rx_data <= 8'h00;
        rx_shift_reg <= 8'h00;
    end else begin
        if (rx_done)
            rx_done <= 1'b0;

        case (rx_state)

            IDLE: begin
                rx_clk_count <= 0;
                rx_bit_count <= 0;

                if (rx_d2 == 1'b0)
                    rx_state <= START;
            end

            START: begin
                if (rx_clk_count == (CLKS_PER_BIT - 1) / 2) begin
                    if (rx_d2 == 1'b0)
                        rx_clk_count <= rx_clk_count + 1'b1;
                    else
                        rx_state <= IDLE;
                end else if (rx_clk_count < CLKS_PER_BIT - 1) begin
                    rx_clk_count <= rx_clk_count + 1'b1;
                end else begin
                    rx_clk_count <= 0;
                    rx_state <= DATA;
                end
            end

            DATA: begin
                if (rx_clk_count == (CLKS_PER_BIT - 1) / 2) begin
                    rx_shift_reg <= {rx_d2, rx_shift_reg[7:1]};
                    rx_clk_count <= rx_clk_count + 1'b1;
                end else if (rx_clk_count < CLKS_PER_BIT - 1) begin
                    rx_clk_count <= rx_clk_count + 1'b1;
                end else begin
                    rx_clk_count <= 0;

                    if (rx_bit_count < 7)
                        rx_bit_count <= rx_bit_count + 1'b1;
                    else begin
                        rx_bit_count <= 0;
                        rx_state <= STOP;
                    end
                end
            end

            STOP: begin
                if (rx_clk_count < CLKS_PER_BIT - 1)
                    rx_clk_count <= rx_clk_count + 1'b1;
                else begin
                    rx_done <= 1'b1;
                    rx_data <= rx_shift_reg;
                    rx_clk_count <= 0;
                    rx_state <= IDLE;
                end
            end

            default: rx_state <= IDLE;
        endcase
    end
end

endmodule