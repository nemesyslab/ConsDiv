module FA1(A,B,CI,S,CO);

input A,B,CI;
output CO,S;

assign S = (A^B)^CI;
assign CO = (A&B)|(CI&(A|B));

endmodule
