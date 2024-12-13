`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module spi(
input clk,start,
input [11:0] din, //data to transmit
output reg cs,mosi,done, //cs:chip select ,mosi :transmitting channel
output sclk);
 
 integer count=0;
 reg scklt=0;
 always@(posedge clk)
 begin //slower clk is 1/10 of clk 
 if(count<10)
 count<=count+1;
 else   begin 
 count<=0;
 scklt<=~scklt;
 end
end 

////////////////
parameter idle=0,start_tx=1,send=2,end_tx=3;
reg [1:0] state=idle;
reg [11:0] temp;
integer bitcount=0;//number of bits transmitted so far (0-11)

always@(posedge scklt)
begin 
case(state)
idle:begin  
mosi<=0;
cs<=1; //during idle state cs=1
done<=0;
if(start)
state<=start_tx; //go to start transition state
else
state<=idle;//or remain in idle state
end 

start_tx:begin  
cs<=0;//cs becomes 0 during transmision
temp<=din;
state<=send;
end 

send:begin  
if(bitcount<=11)//remain in sending state
begin 
bitcount<=bitcount+1;//increment bit
mosi=temp[bitcount]; //send msb bit into mosi channel
state<=send;
end
else begin 
bitcount<=0;
state<=end_tx; 
mosi<=0;
end
end

end_tx:begin    
done<=1;
state<=idle;
cs<=1;
end 

default: state<=idle;
endcase
end
assign sclk=scklt;
endmodule
