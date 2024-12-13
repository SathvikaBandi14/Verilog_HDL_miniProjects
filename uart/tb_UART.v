`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.12.2024 12:00:24
// Design Name: 
// Module Name: tb_UART
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_UART;
reg clk=0;
reg start=0;
reg [7:0]txin;
wire [7:0] rxout;
wire rxdone,txdone;
wire txrx;

UART dut(clk,start,txin,txrx,txrx,rxout,rxdone,txdone);
integer i=0;

initial 
begin   
start=1;
for(i=0;i<10;i=i+1)
begin 
txin=$urandom_range(10,200);
@(posedge rxdone);
@(posedge txdone);
end 
$stop;
end 

always #5 clk=~clk;
endmodule
