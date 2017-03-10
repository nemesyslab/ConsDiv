#!/usr/bin/perl 

open(wrapperFile, "> Wrapper.v");

if($ARGV[0] =~ /([0-9]+)(b?)x([0-9]+)b(.*)/i)
{
	($first, $mult, $second, $satur) = ($1, $2, $3, $4);
}

if($mult eq "b")	
{
	print STDERR "Wrong format for Wrapper generator! \n";
	exit -1;
}


if($satur ne "") # if there exist saturation 
{
	$outBit = $satur;
}
else 
{
	$outBit = myLog2($first) +$second; 
}
	
print wrapperFile "module Wrapper (clk, in2, in, sum); \n\n";
print wrapperFile "input clk; \n";
print wrapperFile "input [" . ($second -1) . ":0] in; \n";
print wrapperFile "input [" . ($first -1) . ":0] in2; \n";
print wrapperFile "output reg [" . ($outBit -1) . ":0] sum; \n\n";
for($ii = 0; $ii < $first; $ii++)
{
	print wrapperFile "reg [" . ($second -1) . ":0] in" . $ii . "_f; \n";
}
print wrapperFile "wire [" . ($outBit -1) . ":0] sum_f; \n\n";
for($ii = 0; $ii < $first; $ii++)
{
	print wrapperFile "wire [" . ($second -1) . ":0] in" . $ii . "_tmp = in & {" . $second . "{in2[" . $ii . "]}}; \n";
}					
print wrapperFile "\nalways @ (posedge clk) begin \n";
for($ii = 0; $ii < $first; $ii++)
{
	print wrapperFile "\tin" . $ii . "_f <= in" . $ii . "_tmp ; \n";
}			
print wrapperFile "\tsum <= sum_f; \n";
print wrapperFile "end\n";

print wrapperFile "\nMult inst1 (";
for($ii = 0; $ii < $first; $ii++)
{
	print wrapperFile "in" . $ii . "_f, "; 
}
print wrapperFile "sum_f);\n\n";
print wrapperFile "endmodule\n\n";

close wrapperFile ;

# myLog2 
sub myLog2
{
        my $in = $_[0] -1;
        $cntr = 0;

        while ($in != 0)
        {
                $in = $in >> 1;
                $cntr++;
        }
        return $cntr;
}
