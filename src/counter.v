module counter
(
    input clk,
    output [5:0] led
);

localparam MS_TICK = 27000;
reg [5:0] ledCntr = 0;
reg [23:0] clkCntr = 0;

always @(posedge clk) begin

    clkCntr <= clkCntr + 1;
    if (clkCntr == (MS_TICK * 50)) begin
        clkCntr <= 0;
        ledCntr <= ledCntr + 1;
    end
end 

assign led = ledCntr;
endmodule
