####--TestBench Verilog Code Generation (TestBench.v)--####
if ($input_mode == 1)
{
	open TESTBENCH, ">TestBench.v";
		print TESTBENCH "module CST_tb();\n\n";
		print TESTBENCH "reg [",$num1-1,":0] in1;\n"; 
		print TESTBENCH "reg [",$num2-1,":0] in2;\n";
		print TESTBENCH "reg [",$length-1,":0] tb_out;\n";
		print TESTBENCH "wire [",$length-1,":0] design_out;\n";
		print TESTBENCH "reg clk, rst;\n\n";
		print TESTBENCH "reg[9:0] cntr; \n";
		print TESTBENCH "Mult inst1(\n";
		print TESTBENCH "\tin1,\n\tin2,\n";
		print TESTBENCH "\tdesign_out[",$length-1,":0]);\n\n";
		print TESTBENCH "initial begin\n\tclk = 0;\n\tcntr = 10'b0;\n\t#5 rst = 1;\n\t#15 rst = 0;\nend\n\n";
		print TESTBENCH "always begin\n\t#10 clk = ~clk;\nend\n\n";
		print TESTBENCH "always @(posedge clk) begin\n\tif (rst) begin\n\t\t";
		print TESTBENCH "in1"," <= ",$num1,"'b0;\n\t\t";
		print TESTBENCH "in2"," <= ",$num2,"'b0;\n\t\t";
		print TESTBENCH "\n\tend\n\t";
		print TESTBENCH "else begin\n\t\t";
		print TESTBENCH "in1"," <= \$","random;\n\t\t";
		print TESTBENCH "in2"," <= \$","random;\n\t\t";
		print TESTBENCH "\n\tend\n";
		print TESTBENCH "end\n\n";
		print TESTBENCH "always @(*) begin\n\ttb_out <= ";
		print TESTBENCH "in1 * in2";
		print TESTBENCH ";\nend\n\n";
		print TESTBENCH "always @(posedge clk) begin\n\t#2\n\t";
		print TESTBENCH "if (design_out == tb_out) begin\n\t\t";
		print TESTBENCH "\$display (\"Time = %d\t design_output = %d\t testbenc_output = %d\t --> CORRECT\", \$time, design_out, tb_out);\n\t";
		print TESTBENCH "end\n\t";
		print TESTBENCH "else begin\n\t\t";
		print TESTBENCH "\$display (\"Time = %d\t design_output = %d\t testbenc_output = %d\t --> ERROR\", \$time, design_out, tb_out);\n\t";
		print TESTBENCH "end\n";
		print TESTBENCH "if(cntr == 10'd100) begin \$finish; end \n";
		print TESTBENCH "cntr <= cntr + 10'b1; \n";
		print TESTBENCH "end\n";
		print TESTBENCH "endmodule\n";
	close (TESTBENCH);
}
elsif ($input_mode == 2)
{
	open TESTBENCH, ">TestBench.v";
		print TESTBENCH "module CST_tb();\n\n";
		for($i=0;$i<$num1;$i++)
		{
			print TESTBENCH "reg [",$num2-1,":0] in",$i,";\n";
		}
		print TESTBENCH "reg [",$length-1,":0] tb_out;\n";
		print TESTBENCH "wire [",$length-1,":0] design_out;\n";
		print TESTBENCH "reg clk, rst;\n\n";
		print TESTBENCH "reg[9:0] cntr; \n";
		print TESTBENCH "Mult inst1(\n";
		for($i=0;$i<$num1;$i++)
		{
			print TESTBENCH "\tin",$i,",\n";
		}
		print TESTBENCH "\tdesign_out\n);\n\n";
		print TESTBENCH "initial begin\n\tclk = 0;\n\tcntr = 10'b0;\n\t#5 rst = 1;\n\t#15 rst = 0;\nend\n\n";
		print TESTBENCH "always begin\n\t#10 clk = ~clk;\nend\n\n";
		print TESTBENCH "always @(posedge clk) begin\n\tif (rst) begin\n\t\t";
		for($i=0;$i<$num1;$i++)
		{
			print TESTBENCH "in",$i," <= ",$num2,"'b0;\n\t\t";
		}
		print TESTBENCH "\n\tend\n\t";
		print TESTBENCH "else begin\n\t\t";
		for($i=0;$i<$num1;$i++)
		{
			print TESTBENCH "in",$i," <= \$","random;\n\t\t";
		}
		print TESTBENCH "\n\tend\n";
		print TESTBENCH "end\n\n";
		print TESTBENCH "always @(*) begin\n";
		print TESTBENCH "\ttb_out = ";
		for($i=0;$i<$num1-1;$i++)
		{
			print TESTBENCH "in",$i,"+";
		}
		print TESTBENCH "in",$num1-1,";\n";
		print TESTBENCH "end\n\n";
		print TESTBENCH "always @(posedge clk) begin\n\t#2\n\t";
		print TESTBENCH "if (design_out == tb_out) begin\n\t\t";
		print TESTBENCH "\$display (\"Time = %d\t design_output = %d\t testbenc_output = %d\t --> CORRECT\", \$time, design_out, tb_out);\n\t";
		print TESTBENCH "end\n\t";
		print TESTBENCH "else begin\n\t\t";
		print TESTBENCH "\$display (\"Time = %d\t design_output = %d\t testbenc_output = %d\t --> ERROR\", \$time, design_out, tb_out);\n\t";
		print TESTBENCH "end\n";
		print TESTBENCH "if(cntr == 10'd100) begin \$finish; end \n";
		print TESTBENCH "cntr <= cntr + 10'b1; \n";
		print TESTBENCH "end\n";
		print TESTBENCH "endmodule\n";
	close (TESTBENCH);
}
elsif ($input_mode == 3)
{
	open TESTBENCH, ">TestBench.v";
		print TESTBENCH "module CST_tb();\n\n";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print TESTBENCH "\treg ",$bitarray [0][$j][$k]->name,";\n";
				}
			}	
		}
		print TESTBENCH "\treg [",$length-1,":0] tb_out;\n";
		print TESTBENCH "\twire [",$length-1,":0] design_out;\n";
		print TESTBENCH "\treg clk, rst;\n\n";
		print TESTBENCH "reg[9:0] cntr; \n";
		print TESTBENCH "Mult inst1(\n";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print TESTBENCH "\t",$bitarray [0][$j][$k]->name,",\n";
				}
			}	
		}
		print TESTBENCH "\tdesign_out\n);\n\n";
		print TESTBENCH "initial begin\n\tclk = 0;\n\tcntr = 10'b0;\n\t#5 rst = 1;\n\t#15 rst = 0;\nend\n\n";
		print TESTBENCH "always begin\n\t#10 clk = ~clk;\nend\n\n";
		print TESTBENCH "always @(posedge clk) begin\n\tif (rst) begin\n\t\t";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print TESTBENCH $bitarray [0][$j][$k]->name," <= 1'b0;\n\t\t";
				}
			}	
		}
		print TESTBENCH "\n\tend\n\t";
		print TESTBENCH "else begin\n\t\t";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print TESTBENCH $bitarray [0][$j][$k]->name," <= \$","random;\n\t\t";
				}
			}	
		}
		print TESTBENCH "\n\tend\n";
		print TESTBENCH "end\n\n";
		print TESTBENCH "always @(*) begin\n";
		print TESTBENCH "\ttb_out = ";
		for ($j=0;$j<$rownum;$j++)
		{	
			print TESTBENCH "{";
			for ($k=$length-1;$k>=0;$k--)
			{
				if($bitarray [0][$j][$k] != 0)
				{
					print TESTBENCH $bitarray [0][$j][$k]->name;
				}
				else
				{
					print TESTBENCH "1'b0";
				}
				if ($k!=0)
				{
					print TESTBENCH ",";
				}
			}
			print TESTBENCH "}";
			if ($j!=$rownum-1)
			{
				print TESTBENCH "+";
			}
		}
		print TESTBENCH ";\n";
		print TESTBENCH "end\n\n";
		print TESTBENCH "always @(posedge clk) begin\n\t#2\n\t";
		print TESTBENCH "if (design_out == tb_out) begin\n\t\t";
		print TESTBENCH "\$display (\"Time = %d\t design_output = %d\t testbenc_output = %d\t --> CORRECT\", \$time, design_out, tb_out);\n\t";
		print TESTBENCH "end\n\t";
		print TESTBENCH "else begin\n\t\t";
		print TESTBENCH "\$display (\"Time = %d\t design_output = %d\t testbenc_output = %d\t --> ERROR\", \$time, design_out, tb_out);\n\t";
		print TESTBENCH "end\n";
		print TESTBENCH "if(cntr == 10'd100) begin \$finish; end \n";
		print TESTBENCH "cntr <= cntr + 10'b1; \n";
		print TESTBENCH "end\n";
		print TESTBENCH "endmodule\n";
	close (TESTBENCH); 
} 
###########################################################

1;#require needs "1" to be returned