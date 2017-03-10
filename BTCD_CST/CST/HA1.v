module HA1(A,B,S,CO);

input A,B;
output CO,S;

assign S = A^B;
assign CO = (A&B);

endmodule
