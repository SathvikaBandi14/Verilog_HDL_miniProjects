`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////


module bist(
input clk,rst,
input [3:0] sw,
output [3:0] led
    );
    
integer count=0;
reg sclk=0;

always@(posedge clk)////// 10^8 -> 1/10^8 * __=1s
begin
if(count<10) ///N/2 for getting clock frequency of 1s so that output changes every second from 0000->1000->1100->1110->1111
count=count+1;
else
begin
count<=0;
sclk=~sclk;
end
end    

///////
reg flag=0;
always@(posedge clk)
begin 
if(sw==0) //radom pattern
flag<=0;
else
flag<=1;// loads switch data into led
end
//////////////
integer i=0;
reg [3:0] temp=0;
always@(posedge sclk)
begin
if(flag==0)
begin 
if(i<4)
begin 
temp<={1'b1,temp[3:1]}; //right shift
i<=i+1;
end 
else if(i<8)
begin 
temp<={temp[2:0],1'b0};//left shift x
i<=i+1;
end 
else 
begin 
i<=0;
temp<=0;
end
end 
else 
temp<=sw;
end 
assign led=temp;
endmodule
