`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////


module pwm(
input clk,rst,
output reg dout);

parameter period=100;
integer ton=0; //time on
integer count=0;
parameter up=0,down=1;
reg state;

reg ncyc=0;//new cycle (end of period)
always@(posedge clk)
begin   
 if(rst)
begin   
ton<=0;
count<=0;
ncyc<=0;
end
else 
begin 
if(count<=ton)
begin
count<=count+1;
ncyc<=0;
dout<=1;
end 

else if(count<period)
begin 
count<=count+1;
ncyc<=0;
dout<=0;
end 

else 
begin 
ncyc<=1;
count<=0;
end 
end 
end

always@(posedge clk)
begin   
if(rst==0)
begin   
if(ncyc==1)
begin
case(state)
up: 
begin
if(ton<period)    
ton<=ton+5;
else
state<=down;
end 

down:begin 
if(ton>0)
ton<=ton-5;
else 
state<=up;
end

default:state<=up;
endcase
end
end
end
endmodule
