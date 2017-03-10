for ($i=0;$i<=($#guidance);$i++)# ????????????($#guidance+1) yerine ($#guidance) yazmak gerekebilir????????????
{
	if ($random_switch == 1)
	{
#####################--Random Sort--#######################
		for ($j=0;$j<$length;$j++)
		{
			$k = $cstlevels[$i][$j];
			if ($k >= 2){
				for ($ii=0;$ii<=$k;$ii++){
					$randarray[$ii] = $bitarray[$i][$ii][$j];
				}
				
				for ($ii=0;$ii<$k;$ii++){
					$temp = $randarray[$ii];
					$randnumber = int (rand($k));
					$randarray[$ii] = $randarray[$randnumber];
					$randarray[$randnumber] = $temp;
				} 
				
				for ($ii=0;$ii<=$k;$ii++){
					 $bitarray[$i][$ii][$j] = $randarray[$ii];
				}
			}
		}	
###########################################################	
	}
	else
	{
####--Sorts Bit Arrays Each Column According to Delay--####
		for ($j=0;$j<$length;$j++)
		{
			for ($k=$cstlevels[$i][$j]-1;$k>=0;$k--)
			{
				for($l=1;$l<=$k;$l++)
				{
					if($bitarray[$i][$l-1][$j]->delay > $bitarray[$i][$l][$j]->delay)
					{
						$temp2 = $bitarray[$i][$l-1][$j];
						$bitarray[$i][$l-1][$j] = $bitarray[$i][$l][$j];
						$bitarray[$i][$l][$j] = $temp2;
					}
				}
			}
		}	
###########################################################	
	}

	
#################--??????????????????????--################
	for($j=0;$j<$length;$j++)
	{
		$bitindex = 0;
		for($x=0;$x<5;$x++)
		{
			for($k=0;$k<int($celllevels[$i][$j]+0.5);$k++)
			{
				if($delayarray[$x]->celltype == $cellarray [$i][$k][$j]->celltype)
				{	
					print $bitarray[$i][$bitindex][$j] -> name,"*";
					$cellarray [$i][$k][$j] -> in($delayarray[$x] -> bitno , $bitarray[$i][$bitindex][$j] -> name);# = $bitarray[$i][$bitindex][$j] -> name;
					$bitarray[$i][$bitindex][$j] -> in(1);# = 1;
					if ($cellarray [$i][$k][$j] -> celltype == 1)
					{
						if(($FASumDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay) > $cellarray [$i][$k][$j] -> maxsumdelay)
						{
							$cellarray [$i][$k][$j] -> maxsumdelay(($FASumDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay));# = ($FASumDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay);
						}
						if(($FACoutDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay) > $cellarray [$i][$k][$j] -> maxcoutdelay)
						{
							$cellarray [$i][$k][$j] -> maxcoutdelay(($FACoutDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay));# = ($FACoutDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay);
						}
					}
					else
					{
						if(($HASumDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay) > $cellarray [$i][$k][$j] -> maxsumdelay)
						{
							$cellarray [$i][$k][$j] -> maxsumdelay(($HASumDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay));# = ($HASumDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay);
						}
						if(($HACoutDelay[$delayarray[$x]->bitno] + $bitarray[$i][$bitindex][$j] -> delay) > $cellarray [$i][$k][$j]->maxcoutdelay)
						{
							$cellarray [$i][$k][$j] -> maxcoutdelay(($HACoutDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay));# = ($HACoutDelay[$delayarray[$x] -> bitno] + $bitarray[$i][$bitindex][$j] -> delay);
						}
					}
					$bitindex++;
				}
							
				
			}
		}
	}		
	print "\n";
	for($j=0;$j<$length;$j++)
	{	
		if ($j == 0)
		{
			$unusedbitlocation = int($celllevels[$i][$j]+0.5);
			for($k=0;$k<int($celllevels[$i][$j]+0.5);$k++)
			{
				$bitarray[$i+1][$k][$j] = Bit -> new(name => $cellarray[$i][$k][$j]->sum,delay => $cellarray[$i][$k][$j]->maxsumdelay,in => 0);
			}
			for($k=0;$k<$cstlevels[$i][$j];$k++)
			{
				if($bitarray[$i][$k][$j]->in == 0)# in parametresi gereksiz bitarray sort edildiði için (FA*3+HA*2) tane eleamandan sonrakilerin sadece in parametresi 0 olur
				{
					$bitarray[$i+1][$unusedbitlocation][$j] = $bitarray[$i][$k][$j];#kopyalamak yerine new ile yeni oluþturmak gerekebilir
					$unusedbitlocation++;
				}
			}

		}
		else
		{
			$unusedbitlocation = int($celllevels[$i][$j]+0.5)+int($celllevels[$i][$j-1]+0.5);
			for($k=0;$k<int($celllevels[$i][$j]+0.5);$k++)
			{
				$bitarray[$i+1][$k][$j] = Bit -> new(name => $cellarray[$i][$k][$j]->sum,delay => $cellarray[$i][$k][$j]->maxsumdelay,in => 0);
			}
			for($k=0;$k<int($celllevels[$i][$j-1]+0.5);$k++)
			{
				$bitarray[$i+1][int($celllevels[$i][$j]+0.5)+$k][$j] = Bit -> new(name => $cellarray[$i][$k][$j-1]->cout,delay => $cellarray[$i][$k][$j-1]->maxcoutdelay,in => 0);
			}
			for($k=0;$k<$cstlevels[$i][$j];$k++)
			{
				if($bitarray[$i][$k][$j]->in == 0)# in parametresi gereksiz bitarray sort edildiði için (FA*3+HA*2) tane eleamandan sonrakilerin sadece in parametresi 0 olur
				{
					$bitarray[$i+1][$unusedbitlocation][$j] = $bitarray[$i][$k][$j];#kopyalamak yerine new ile yeni oluþturmak gerekebilir
					$unusedbitlocation++;
				}
			}
		}
	}
	
###########################################################	

}

###################--Prints Delay Table--##################
for($i=0;$i<=($#guidance+1);$i++)
{
	for ($j=0;$j<$length;$j++)
	{
		$printsize[$i][$j] = 0;
	}
}

for($i=0;$i<=($#guidance+1);$i++)
{
	for ($j=0;$j<$length;$j++)
	{
		for($k=0;$k<$rownum;$k++)
		{
			if($bitarray [$i][$k][$j] != 0)
			{
				if(length($bitarray [$i][$k][$j]->delay) > $printsize[$i][$j])
				{
					$printsize[$i][$j] = length($bitarray [$i][$k][$j]->delay);				
				}
			}
		}
	}

}

for ($i=0;$i<=($#guidance+1);$i++)
{
	for ($j=0;$j<$rownum;$j++)
	{
		for ($k=$length-1;$k>=0;$k--)
		{
			if($bitarray [$i][$j][$k] != 0)
			{
				print $bitarray [$i][$j][$k]->delay," " x ($printsize[$i][$k]+2-length($bitarray [$i][$j][$k]->delay));
			}
			else
			{
				print " " x ($printsize[$i][$k]+2);
			}
		}
		print "\n";
	}
	print "\n\n";
}
###########################################################

####--FullAdder Verilog Code Generation (FullAdder.v)--####
open FULLADDER, "> FA1.v";
	print FULLADDER "module FA1(A,B,CI,S,CO);\n\n";
	print FULLADDER "input A,B,CI;\n";
	print FULLADDER "output CO,S;\n\n";
	print FULLADDER "assign S = (A^B)^CI;\n";
	print FULLADDER "assign CO = (A&B)|(CI&(A|B));\n\n";
	print FULLADDER "endmodule\n";
close (FULLADDER); 
###########################################################

####--HalfAdder Verilog Code Generation (HalfAdder.v)--####
open HALFADDER, "> HA1.v";
	print HALFADDER "module HA1(A,B,S,CO);\n\n";
	print HALFADDER "input A,B;\n";
	print HALFADDER "output CO,S;\n\n";
	print HALFADDER "assign S = A^B;\n";
	print HALFADDER "assign CO = (A&B);\n\n";
	print HALFADDER "endmodule\n";
close (HALFADDER); 
###########################################################

######--Wrapper Verilog Code Generation (Wrapper.v)--######
if ($input_mode == 1)
{
	open WRAPPER, ">Wrapper.v";
		print WRAPPER "module Wrapper (clk, in1, in2, sum);\n\n";
		print WRAPPER "\tinput clk;\n";
		print WRAPPER "\tinput [",$num1-1,":0] in1;\n";
		print WRAPPER "\tinput [",$num2-1,":0] in2;\n";
		print WRAPPER "\toutput [",$length-1,":0] sum;\n";
		print WRAPPER "\treg [",$num1-1,":0] in1_f;\n";
		print WRAPPER "\treg [",$num2-1,":0] in2_f;\n";
		print WRAPPER "\treg [",$length-1,":0] sum;\n";
		print WRAPPER "\twire [",$length-1,":0] sum_f;\n\n";
		print WRAPPER "\talways @ (posedge clk)\n";
		print WRAPPER "\t\tbegin\n";
		print WRAPPER "\t\tin1_f <= in1;\n";
		print WRAPPER "\t\tin2_f <= in2;\n";
		print WRAPPER "\t\tsum <= sum_f;\n";
		print WRAPPER "\tend\n\n";
		print WRAPPER "\tMult inst1 (in1_f,in2_f,sum_f);\n\n";
		print WRAPPER "endmodule\n";
	close(WRAPPER);
}
elsif ($input_mode == 2)
{
	open WRAPPER, ">Wrapper.v";
		print WRAPPER "module Wrapper (clk,";
		for($i=0;$i<$num1;$i++)
		{
			print WRAPPER " in",$i,",";
		}
		print WRAPPER " sum);\n\n";
		print WRAPPER "\tinput clk;\n";
		for($i=0;$i<$num1;$i++)
		{
			print WRAPPER "\tinput [",$num2-1,":0] in",$i,";\n";
		}
		print WRAPPER "\toutput [",$length-1,":0] sum;\n";
		for($i=0;$i<$num1;$i++)
		{
			print WRAPPER "\treg [",$num2-1,":0] in",$i,"_f;\n";
		}
		print WRAPPER "\treg [",$length-1,":0] sum;\n";
		print WRAPPER "\twire [",$length-1,":0] sum_f;\n\n";
		print WRAPPER "\talways @ (posedge clk)\n";
		print WRAPPER "\tbegin\n";
		for($i=0;$i<$num1;$i++)
		{
			print WRAPPER "\t\tin",$i,"_f <= in",$i,";\n";
		}
		print WRAPPER "\t\tsum <= sum_f;\n";
		print WRAPPER "\tend\n\n";
		print WRAPPER "\tMult inst1 (";
		for($i=0;$i<$num1;$i++)
		{
			print WRAPPER " in",$i,"_f,";
		}
		print WRAPPER " sum_f);\n\n";
		print WRAPPER "endmodule\n";
	close(WRAPPER);
}
elsif ($input_mode == 3)
{
	open WRAPPER, ">Wrapper.v";
		print WRAPPER "module Wrapper (\n\tclk,\n";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print WRAPPER "\t",$bitarray [0][$j][$k]->name,",\n";
				}
			}	
		}

		print WRAPPER "\tsum\n);\n\n";
		print WRAPPER "\tinput clk;\n";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print WRAPPER "\tinput ",$bitarray [0][$j][$k]->name,";\n";
				}
			}	
		}
		
		print WRAPPER "\toutput [",$length-1,":0] sum;\n\n";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print WRAPPER "\treg ",$bitarray [0][$j][$k]->name,"_f;\n";
				}
			}	
		}
		print WRAPPER "\twire [",$length-1,":0] sum_f;\n";
		print WRAPPER "\treg [",$length-1,":0] sum;\n\n";
		print WRAPPER "always @ (posedge clk) begin\n";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print WRAPPER "\t",$bitarray [0][$j][$k]->name,"_f <= ",$bitarray [0][$j][$k]->name,";\n";
				}
			}	
		}
		print WRAPPER "\tsum <= sum_f;\n";
		print WRAPPER "end\n\n";
		print WRAPPER "Mult inst1 (\n";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print WRAPPER "\t",$bitarray [0][$j][$k]->name,"_f,\n";
				}
			}	
		}
		print WRAPPER "\tsum_f\n);\n\n";
		print WRAPPER "endmodule";
	close (WRAPPER);
}
###########################################################

$instance_count = 0;
if ($input_mode == 1)
{
	open Mult, ">Mult.v";
		print Mult "module Mult (in1,in2,sum);\n";
		print Mult "\tinput [",$num1-1,":0] in1;\n";
		print Mult "\tinput [",$num2-1,":0] in2;\n";
		print Mult "\toutput [",$length-1,":0] sum;\n";
		
		for ($i=0;$i<=$#guidance;$i++)
		{
			for ($j=0;$j<$rownum;$j++)
			{
				for ($k=0;$k<$length;$k++)
				{	
					if($cellarray [$i][$j][$k] != 0)
					{
						if($cellarray [$i][$j][$k]->celltype == 0)#HA(in0,in1,sum,cout)
						{
							print Mult "\twire ",$cellarray [$i][$j][$k]->in(0),",",$cellarray [$i][$j][$k]->in(1),";\n";                                                                              
						}
						else#FA(in0,in1,in2,sum,cout)
						{
							print Mult "\twire ",$cellarray [$i][$j][$k]->in(0),",",$cellarray [$i][$j][$k]->in(1),",",$cellarray [$i][$j][$k]->in(2),";\n";                                                                                     
						}
					}
				}
			
			}
		}	
		

		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [$#guidance+1][$j][$k] != 0)
				{
					print Mult "\twire ",$bitarray [$#guidance+1][$j][$k]->name,";\n";
				}
			}
		
		}

		
		
		print Mult "\n";
		
		for($i=0;$i<$num1;$i++)
		{
			print Mult "\tassign {";
			for($j=0;$j<$num2;$j++)
			{
				print Mult "Bit_0_";
				if ($i > $j)
				{
					print Mult $i-($i-$j);
				}
				else
				{
					print Mult $i;
				}	
				print Mult "_",$num2-$j-1+$i;
				if ($j != $num2 -1)
				{
					print Mult ",";
				}
			}
			print Mult "} = {",$num2,"{in1[",$i,"]}} & in2;\n";
		}
		
		print Mult "\n"; 
		
		$halfadder = 0;
		$fulladder = 0;
		
		for ($i=0;$i<=$#guidance;$i++)
		{
			for ($j=0;$j<$rownum;$j++)
			{
				for ($k=0;$k<$length;$k++)
				{	
					if($cellarray [$i][$j][$k] != 0)
					{
						if($cellarray [$i][$j][$k]->celltype == 0)#HA(in0,in1,sum,cout)
						{
							print Mult "\tHA1 inst",$instance_count," (",".A(",$cellarray [$i][$j][$k]->in(0),"),.B(",$cellarray [$i][$j][$k]->in(1),"),.S(",$cellarray [$i][$j][$k]->sum,"),.CO(",$cellarray [$i][$j][$k]->cout,"));\n";                                                                              
							$instance_count += 1;
							$halfadder ++;
						}
						else#FA(in0,in1,in2,sum,cout)
						{
							print Mult "\tFA1 inst",$instance_count," (.A(",$cellarray [$i][$j][$k]->in(0),"),.B(",$cellarray [$i][$j][$k]->in(1),"),.CI(",$cellarray [$i][$j][$k]->in(2),"),.S(",$cellarray [$i][$j][$k]->sum,"),.CO(",$cellarray [$i][$j][$k]->cout,"));\n";                                                                                     
							$instance_count += 1;
							$fulladder ++;
						}
					}
				}
			
			}
		}
		($max,$index) = &findmax(@temparray);
		open CELL, ">>Cell.log";
			print CELL $num1,"x",$num2,"\n\n";
			print CELL "FullAdder: ",$fulladder,"\n";
			print CELL "HalfAdder: ",$halfadder,"\n";
			print CELL "Width: ",$num1+$num2-$index-1,"\n\n";;
			print CELL "--------------------------------\n\n";
		close (CELL);
		
		print Mult "\n\t//infer DW01_ADD__BK";
		print Mult "\n\tassign sum = {";
		
		for ($k=$length-1;$k>=0;$k--)
		{
			if ($bitarray [$#guidance+1][0][$k] != 0)
			{
				print Mult $bitarray [$#guidance+1][0][$k]->name;
				if ($k!=0)
				{
					print Mult ",";
				}
			}
			else 
			{
				print Mult "1'b0";
				if ($k!=0)
				{
					print Mult ",";
				}
			}
		}
		
		print Mult "} + {";
		
		for ($k=$length-1;$k>=0;$k--)
		{
			if ($bitarray [$#guidance+1][1][$k] != 0)
			{
				print Mult $bitarray [$#guidance+1][1][$k]->name;
				if ($k!=0)
				{
					print Mult ",";
				}
			}
			else 
			{
				print Mult "1'b0";
				if ($k!=0)
				{
					print Mult ",";
				}
			}
		}

		print Mult "};\n";
			
		print Mult "\nendmodule\n";	
			
	close (Mult); 
}
elsif ($input_mode == 2)
{
	open Mult, ">CST" . $num1 . "x" . $num2 . "b.v";
		print Mult "module CST" . $num1 . "x" . $num2 . "b (";
		for($i=0;$i<$num1;$i++)
		{
			print Mult " in",$i,",";
		}
		print Mult "sum);\n\n";
		for($i=0;$i<$num1;$i++)
		{
			print Mult "\tinput [",$num2-1,":0] in",$i,";\n";
		}
		print Mult "\toutput [",$length-1,":0] sum;\n\n";
		
		for ($i=0;$i<=$#guidance;$i++)
		{
			for ($j=0;$j<$rownum;$j++)
			{
				for ($k=0;$k<$length;$k++)
				{	
					if($cellarray [$i][$j][$k] != 0)
					{
						if($cellarray [$i][$j][$k]->celltype == 0)#HA(in0,in1,sum,cout)
						{
							print Mult "\twire ",$cellarray [$i][$j][$k]->in(0),",",$cellarray [$i][$j][$k]->in(1),";\n";                                                                              
						}
						else#FA(in0,in1,in2,sum,cout)
						{
							print Mult "\twire ",$cellarray [$i][$j][$k]->in(0),",",$cellarray [$i][$j][$k]->in(1),",",$cellarray [$i][$j][$k]->in(2),";\n";                                                                                     
						}
					}
				}
			
			}
		}	
		
		
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [$#guidance+1][$j][$k] != 0)
				{
					print Mult "\twire ",$bitarray [$#guidance+1][$j][$k]->name,";\n";
				}
			}
		
		}
		
		
		print Mult "\n";
		
		for($i=0;$i<$num1;$i++)
		{
			print Mult "\tassign {";
			for($j=$num2-1;$j>=0;$j--)
			{
				print Mult "Bit_0_",$i,"_",$j;
				if ($j != 0)
				{
					print Mult ",";
				}
			}
			print Mult "} = in",$i,";\n";
		}
		
		print Mult "\n";
				
		for ($i=0;$i<=$#guidance;$i++)
		{
			for ($j=0;$j<$rownum;$j++)
			{
				for ($k=0;$k<$length;$k++)
				{	
					if($cellarray [$i][$j][$k] != 0)
					{
						if($cellarray [$i][$j][$k]->celltype == 0)#HA(in0,in1,sum,cout)
						{
							print Mult "\tHA1 inst",$instance_count," (",".A(",$cellarray [$i][$j][$k]->in(0),"),.B(",$cellarray [$i][$j][$k]->in(1),"),.S(",$cellarray [$i][$j][$k]->sum,"),.CO(",$cellarray [$i][$j][$k]->cout,"));\n";                                                                              
							$instance_count += 1;
						}
						else#FA(in0,in1,in2,sum,cout)
						{
							print Mult "\tFA1 inst",$instance_count," (.A(",$cellarray [$i][$j][$k]->in(0),"),.B(",$cellarray [$i][$j][$k]->in(1),"),.CI(",$cellarray [$i][$j][$k]->in(2),"),.S(",$cellarray [$i][$j][$k]->sum,"),.CO(",$cellarray [$i][$j][$k]->cout,"));\n";                                                                                     
							$instance_count += 1;
						}
					}
				}
			
			}
		}

		
		print Mult "\n\t//infer DW01_ADD__BK";
		print Mult "\n\tassign sum = {";
		
		for ($k=$length-1;$k>=0;$k--)
		{
			if ($bitarray [$#guidance+1][0][$k] != 0)
			{
				print Mult $bitarray [$#guidance+1][0][$k]->name;
				if ($k!=0)
				{
					print Mult ",";
				}
			}
			else 
			{
				print Mult "1'b0";
				if ($k!=0)
				{
					print Mult ",";
				}
			}
		}
		
		print Mult "} + {";
		
		for ($k=$length-1;$k>=0;$k--)
		{
			if ($bitarray [$#guidance+1][1][$k] != 0)
			{
				print Mult $bitarray [$#guidance+1][1][$k]->name;
				if ($k!=0)
				{
					print Mult ",";
				}
			}
			else 
			{
				print Mult "1'b0";
				if ($k!=0)
				{
					print Mult ",";
				}
			}
		}

		print Mult "};\n";
			
		print Mult "\nendmodule\n";	
			
	close (Mult); 
}
		
elsif ($input_mode == 3)
{
	open Mult, ">Mult.v";
		print Mult "module Mult (\n";
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print Mult "\t",$bitarray [0][$j][$k]->name,",\n";
				}
			}	
		}

		print Mult "\tsum\n);\n";
		
		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [0][$j][$k] != 0)
				{
					print Mult "\tinput ",$bitarray [0][$j][$k]->name,";\n";
				}
			}	
		}
		
		print Mult "\toutput [",$length-1,":0] sum;\n\n";
		
		for ($i=0;$i<=$#guidance;$i++)
		{
			for ($j=0;$j<$rownum;$j++)
			{
				for ($k=0;$k<$length;$k++)
				{	
					if($cellarray [$i][$j][$k] != 0)
					{
						if($cellarray [$i][$j][$k]->celltype == 0)#HA(in0,in1,sum,cout)
						{
							if ($cellarray [$i][$j][$k]->in(0) =~ /Bit_0.*/ )
							{}
							else
							{
								print Mult "\twire ",$cellarray [$i][$j][$k]->in(0),";\n";
							}
							if ($cellarray [$i][$j][$k]->in(1) =~ /Bit_0.*/ )
							{}
							else
							{
								print Mult "\twire ",$cellarray [$i][$j][$k]->in(1),";\n";  
							}							
						}
						else#FA(in0,in1,in2,sum,cout)
						{
							if ($cellarray [$i][$j][$k]->in(0) =~ /Bit_0.*/ )
							{}
							else
							{
								print Mult "\twire ",$cellarray [$i][$j][$k]->in(0),";\n";
							}
							if ($cellarray [$i][$j][$k]->in(1) =~ /Bit_0.*/ )
							{}
							else
							{
								print Mult "\twire ",$cellarray [$i][$j][$k]->in(1),";\n";
							}
							if ($cellarray [$i][$j][$k]->in(2) =~ /Bit_0.*/ )
							{}
							else
							{
								print Mult "\twire ",$cellarray [$i][$j][$k]->in(2),";\n";   
							}							
						}
					}
				}
			
			}
		}	
		

		for ($j=0;$j<$rownum;$j++)
		{
			for ($k=0;$k<$length;$k++)
			{
				if ($bitarray [$#guidance+1][$j][$k] != 0)
				{
					print Mult "\twire ",$bitarray [$#guidance+1][$j][$k]->name,";\n";
				}
			}
		
		}
		
		print Mult "\n";

		for ($i=0;$i<=$#guidance;$i++)
		{
			for ($j=0;$j<$rownum;$j++)
			{
				for ($k=0;$k<$length;$k++)
				{	
					if($cellarray [$i][$j][$k] != 0)
					{
						if($cellarray [$i][$j][$k]->celltype == 0)#HA(in0,in1,sum,cout)
						{
							print Mult "\tHA1 inst",$instance_count," (",$cellarray [$i][$j][$k]->in(0),",",$cellarray [$i][$j][$k]->in(1),",",$cellarray [$i][$j][$k]->sum,",",$cellarray [$i][$j][$k]->cout,");\n";                                                                              
							$instance_count += 1;
						}
						else#FA(in0,in1,in2,sum,cout)
						{
							print Mult "\tFA1 inst",$instance_count," (",$cellarray [$i][$j][$k]->in(0),",",$cellarray [$i][$j][$k]->in(1),",",$cellarray [$i][$j][$k]->in(2),",",$cellarray [$i][$j][$k]->sum,",",$cellarray [$i][$j][$k]->cout,");\n";                                                                                     
							$instance_count += 1;
						}
					}
				}
			
			}
		}
		
		print Mult "\n\t//infer DW01_ADD__BK";
		print Mult "\n\tassign sum = {";
		
		for ($k=$length-1;$k>=0;$k--)
		{
			if ($bitarray [$#guidance+1][0][$k] != 0)
			{
				print Mult $bitarray [$#guidance+1][0][$k]->name;
				if ($k!=0)
				{
					print Mult ",";
				}
			}
			else 
			{
				print Mult "1'b0";
				if ($k!=0)
				{
					print Mult ",";
				}
			}
		}
		
		print Mult "} + {";
		
		for ($k=$length-1;$k>=0;$k--)
		{
			if ($bitarray [$#guidance+1][1][$k] != 0)
			{
				print Mult $bitarray [$#guidance+1][1][$k]->name;
				if ($k!=0)
				{
					print Mult ",";
				}
			}
			else 
			{
				print Mult "1'b0";
				if ($k!=0)
				{
					print Mult ",";
				}
			}
		}

		print Mult "};\n";
		
		print Mult "\nendmodule\n";	
				
	close (Mult);
}

1;#require needs "1" to be returned
