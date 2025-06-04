module multidigit(
    input [3:0] dig0,
    input [3:0] dig1,
    input [3:0] dig2,
    input [3:0] dig3,
    input [3:0] dig4,
    input [3:0] dig5,
    input [3:0] dig6,
    input [3:0] dig7,
    output a,
    output b,
    output c,
    output d,
    output e,
    output f,
    output g,
    output reg [7:0] an,
    input clk,
    input rst
);

    reg [2:0] dig_index;
    reg [3:0] dig_out;
    
    // First we instantiate the previously written module. ( .() notation is more robust).
    sevenseg instance0 (.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), .num(dig_out));
    
    // Then we count until 8. With each counter step for one display.
    always @(posedge clk) begin
        if (rst) begin
            dig_index <= 3'b000; // synchronous reset
            
        end else begin
            // Case statement to select which digit to display
            case (dig_index)
                3'b000: dig_out = dig1;
                3'b001: dig_out = dig2;
                3'b010: dig_out = dig3;
                3'b011: dig_out = dig4;
                3'b100: dig_out = dig5;
                3'b101: dig_out = dig6;
                3'b110: dig_out = dig7;
                3'b111: dig_out = dig0;
                default: dig_out = 4'b1111; // display off (active-low)
            endcase
            dig_index <= dig_index + 1; // add 1 to counter on each clock posedge.
        end
    end
    

    // Tp control the "an" output to select the active display,
    // we use a neat trick with the bit-shift operator << which
    // allows us to avoid using a long case statement and makes
    // the hardware description easier to modify in the future
    // for driving more displays.
    always @(*) begin
        an = ~(8'b1 << (dig_index)); // start with 00000001, then shift it to the desired anode, then bitwise NOT for active-low.
    end

endmodule