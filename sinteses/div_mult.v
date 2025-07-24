module div_mult ( 
    input  wire signed [31:0] operand1,     // rs1
    input  wire signed [31:0] operand2,     // rs2
    input  wire [1:0]         mul_div_op,   // Sinal de controle
    output reg  signed [31:0] md_result
);

// mul_div_op:
// 00 -> MUL
// 01 -> DIV
// 10 -> REM
// 11 -> (reservado / nao utilizado)

    reg signed [63:0] mul_temp_result;

    always @(*) begin
        md_result = 32'b0; // Inicializa para evitar latches
        mul_temp_result = 64'b0;

        case (mul_div_op)
            2'b00: begin // MUL
                mul_temp_result = operand1 * operand2;
                md_result       = mul_temp_result[31:0];
            end
            2'b01: begin // DIV
                if (operand2 == 32'd0) begin
                    md_result = 32'hFFFFFFFF;
                end else if (operand1 == 32'h80000000 && operand2 == 32'hFFFFFFFF) begin
                    md_result = 32'h80000000;
                end else begin
                    md_result = operand1 / operand2;
                end
            end
            2'b10: begin // REM
                if (operand2 == 32'd0) begin
                    md_result = operand1;
                end else if (operand1 == 32'h80000000 && operand2 == 32'hFFFFFFFF) begin
                    md_result = 32'd0;
                end else begin
                    md_result = operand1 % operand2;
                end
            end
            default: md_result = 32'b0;
        endcase
    end

endmodule