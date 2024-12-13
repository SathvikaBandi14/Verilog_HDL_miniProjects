module UART(
    input clk,
    input start,
    input [7:0] txin,    // 8-bit data bus
    output reg tx,        // Transmit data serially, output tx line
    input rx,             // Receive data serially
    output [7:0] rxout,   // Data out
    output rxdone,        // Flag marking the data out
    output txdone         // Flag marking reception done
);
    parameter clk_value = 100_000;
    parameter baud = 9600;
    parameter wait_count = clk_value / baud;

    reg bitDone = 0;
    integer count = 0; // Number of clock pulses done/finished
    parameter idle = 0, send = 1, check = 2;
    reg [1:0] state = idle;

    // Generate trigger for baud rate
    always @(posedge clk) begin
        if (state == idle)
            count <= 0;
        else begin
            if (count == wait_count) begin
                bitDone <= 1;
                count <= 0;
            end 
            else begin
                count <= count + 1;
                bitDone <= 0;
            end
        end
    end

    // TX logic
    reg [9:0] txData; // 10-bit data with start and stop bit
    integer bitIndex = 0; // Number of data bits sent so far
    reg [9:0] shifttx=0;

    always @(posedge clk) begin
        case (state)
            idle: begin
                tx <= 1;
                txData <= 0;
                bitIndex <= 0;
                shifttx <= 0;

                if (start) begin
                    txData <= {1'b1, txin, 1'b0}; // Start bit + data + stop bit
                    state <= send;
                end 
                else begin
                    state <= idle;
                end
            end

            send: begin
                tx <= txData[bitIndex]; // Send one bit
                shifttx <= {txData[bitIndex], shifttx[9:1]}; // Shift out the transmitted bit
                state <= check;
            end

            check: begin
                if (bitIndex <= 9) begin //single bit is transmitted(not all bits have been transmitted)
                    if (bitDone) begin
                        state <= send;//send next bit of bus
                        bitIndex <= bitIndex + 1;
                    end
                end else begin //entire txin has been transmitted
                    state <= idle; //wait for next txin
                    bitIndex <= 0;
                end
            end

            default: begin
                state <= idle;
            end
        endcase
    end

    assign txdone = (bitIndex == 9 && bitDone == 1) ? 1:0; // TX done after the 9th bit

    // RX logic
    integer rcount = 0; // Bit is sampled at the middle of the bit duration
    integer rindex = 0;
    parameter ridle = 0, rwait = 1, recv = 2, rcheck = 3;
    reg [1:0] rstate;
    reg [9:0] rxdata;

    always @(posedge clk) begin
        case (rstate)
            ridle: begin
                rxdata <= 0;
                rindex <= 0;
                rcount <= 0;

                if (rx == 0) // Detect start bit (low)
                    rstate <= rwait;
                else
                    rstate <= ridle;
            end

            rwait: begin
                if (rcount < wait_count / 2) begin
                    rcount <= rcount + 1;
                    rstate <= rwait;
                end else begin
                    rcount <= 0;
                    rstate <= recv;
                    rxdata <= {rx, rxdata[9:1]}; // Shift in received bit
                end
            end

            recv: begin
                if (rindex <= 9) begin //all bits are not received
                    if (bitDone) begin
                        rindex <= rindex + 1; //move to next bit
                        rstate <= rwait; //wait for trigger
                    end
                end else begin
                    rstate <= ridle;
                    rindex <= 0;
                end
            end

            default: rstate <= ridle;
        endcase
    end

    assign rxout = rxdata[8:1]; // Output the received data (bits 1-8)
    assign rxdone = (rindex == 9 && bitDone == 1)? 1:0; // RX done when all 8 bits are received
endmodule
