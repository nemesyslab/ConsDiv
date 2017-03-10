#############################################################################################
##                                                                                         ##
##                 EFFICIENT COMBINATIONAL CIRCUITS FOR CONSTANT DIVISION                  ##
##                 					RECIPROCAL METHOD	           ##
##                                                                                         ##
#############################################################################################
##                                                                                         ##
##   Name          : recip.pl                         		                           ##
##   Last Update   : 16.06.2016                                                            ##
##   Designer	   : V. Emre Levent							   ##
##   Description   : 									   ##
##					                                                   ##
##	This perl script that produces division RTL and it's wrapper with given bitWidth   ##
##	and divByN parameters.								   ##
##	 										   ##	
##	Bitwidth represents dividend numbers bitwidth, divByN represents divisor number.   ##
##	During the synthesis process, wrapper is used for frequency measurement purposes.  ##
##											   ##
##	Script finds divisor value and divisor bit width.				   ##
##	Divisor bit width is first smallest smaller or equal bitWidth parameters than 	   ##
##	the exact integer times of (divByN - 1)						   ##
##	Divisor value calculating with (2^(Divisor bit width))/divByN formula		   ##
##                                                                                         ##
#############################################################################################
## Usage perl recip [bitWidth] [divByN]			 				   ##
## Sample call: ">> perl recip 32 3						       	   ##
## 	     This call generates a divider RTL to 3 with bit width 32 		   	   ##
#############################################################################################

#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use POSIX;

my $numbersBitWidth = $ARGV[0];
my $divByN = $ARGV[1];
my $divValBitWidth = $numbersBitWidth +noBits($divByN);
my $divVal = largeHexDiv($divValBitWidth, $divByN);
my $qwidth = $numbersBitWidth -noBits($divByN) +1;
my $rwidth = noBits($divByN);

open(my $fh, '>', 'wrapper.v');
open(my $fh2, '>', 'divBy_' . $divByN . 'N' . $numbersBitWidth . '.v');

generateWrapper();
generateDivByN();

print "Done\n";

sub generateWrapper{

print $fh  "`timescale 1ns / 1ps\n\n";
print $fh "module wrapper(clk,d_p,q_r,r_r);\n\n";

print $fh "	parameter n = $numbersBitWidth;\n";
print $fh "	parameter m = $divValBitWidth;\n";
print $fh "	parameter divVal = $divValBitWidth"."'h$divVal;\n\n";
print $fh "	parameter qw = $qwidth;\n\n";
print $fh "	parameter rw = $rwidth;\n\n";

print $fh "	input clk;\n";
print $fh "	input [n - 1:0] d_p;\n";
print $fh "	output reg [qw - 1:0] q_r;\n";
print $fh "	output reg [rw - 1:0] r_r;\n\n";

print $fh "	reg [n - 1:0] d;\n";
print $fh "	wire [qw - 1:0] q;\n";
print $fh "	wire [rw - 1:0] r;\n";

print $fh "\n";
print $fh "	divBy_$divByN"."N$numbersBitWidth #(n, m, divVal, qw, rw) div(d,q,r);";
print $fh "\n
	always @ (posedge clk) begin
		d <= d_p;
		q_r <= q;
		r_r <= r;
	end\n\n";

print $fh "endmodule\n";

close $fh;
}

sub generateDivByN{

print $fh2 "`timescale 1ns / 1ps\n\n";

print $fh2 "module divBy_$divByN"."N$numbersBitWidth";
print $fh2 " #(parameter n = $numbersBitWidth, m =  $divValBitWidth, divVal = $divValBitWidth"."'h$divVal, qw = $qwidth, rw = $rwidth)\n";
print $fh2 " (addr, q, r);\n\n";

print $fh2 "input [n-1:0] addr; output [qw-1:0] q; output [rw-1:0] r;\n\n";

print $fh2 "	wire [m-1:0] a;\n";
print $fh2 "	assign a = divVal;\n\n";

print $fh2 "	wire [(n+m)-1:0] aTimesX;\n\n";
	
print $fh2 "	assign aTimesX = a * addr;\n";
	
print $fh2 "	wire [(n+m):0] aTimesXPlusa;\n";
print $fh2 "	assign aTimesXPlusa = aTimesX + a;\n\n";
	
print $fh2 "	assign q = aTimesXPlusa >> m;\n";
print $fh2 "	assign r = addr - $divByN * q;\n\n";

print $fh2 "endmodule\n";

close $fh2;

}

sub noBits {
    my $arg = $_[0];
    my $noBits = 0;
    while($arg) {
	$noBits++;
	$arg >>= 1;
    }

    $noBits;
}

sub largeHexDiv {
    my ($bitwidth, $div) = @_;
    my $bits = $bitwidth % 24;

    my ($xx, $qq, $rr);
    my $qqCombined;

    $xx = 2**$bits;

    do {
        my $qq = int($xx/$div);
        my $rr = $xx -$qq*$div;

        $qqCombined .= sprintf("%X", $qq) if($qq);

        $bits += 24;
        $xx = $rr << 24;
    } until($bits > $bitwidth);

    $qqCombined;
}
