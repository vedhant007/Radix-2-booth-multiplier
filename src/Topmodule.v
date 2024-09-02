
//Booth Encoder:


module booth_encoder(input [2:0] booth_in, output reg [1:0] operation);
// operation: 00 = 0, 01 = +M, 10 = -M, 11 = +2M or -2M
always @(*) begin
    case(booth_in)
        3'b000, 3'b111: operation = 2'b00; // 0
        3'b001, 3'b010: operation = 2'b01; // +M
        3'b011:         operation = 2'b11; // +2M
        3'b100:         operation = 2'b10; // -2M
        3'b101, 3'b110: operation = 2'b10; // -M
    endcase
end
endmodule
//Partial Product Generator:

module partial_product(input [1:0] operation, input [N-1:0] multiplicand, output reg [2*N-1:0] pp);
always @(*) begin
    case(operation)
        2'b00: pp = 0;
        2'b01: pp = multiplicand;
        2'b10: pp = ~multiplicand + 1; // Two's complement for -M
        2'b11: pp = multiplicand << 1; // +2M or -2M
    endcase
end
endmodule
Accumulator and Shifter:

//Accumulate the partial products, shifting them accordingly based on their position in the final product.

module booth_multiplier(input [N-1:0] multiplicand, multiplier, output reg [2*N-1:0] product);
reg [2*N-1:0] accumulator;
integer i;
always @(posedge clk) begin
    accumulator = 0;
    for (i = 0; i < N/2; i = i + 1) begin
        // Booth encoding for bits 2*i, 2*i+1, and 2*i-1
        booth_in = {multiplier[2*i+1], multiplier[2*i], i == 0 ? 1'b0 : multiplier[2*i-1]};
        booth_encoder BE(.booth_in(booth_in), .operation(op));
        partial_product PP(.operation(op), .multiplicand(multiplicand), .pp(partial_prod));
        
        // Shift partial product by 2*i positions and accumulate
        accumulator = accumulator + (partial_prod << (2*i));
    end
    product = accumulator;
end
endmodule
