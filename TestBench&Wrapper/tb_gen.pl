#############################################################################################
##                                                                                         ##
##                 EFFICIENT COMBINATIONAL CIRCUITS FOR CONSTANT DIVISION                  ##
##			                  ------- TESTBENCH GENERATOR ----------                           ##
##                                                                                         ##
#############################################################################################
##                                                                                         ##
##   Name          : tb_gen.pl                                                             ##
##   Creation Date : 5.06.2013                                                             ##
##   Description   : TESTBENCH Generator for all division methods.                         ##
##                   Input arguments are divisor and input bitlength.                      ##
##                                                                                         ##
##                                                                                         ##
##                                                                                         ##
##                                                                       by ANIL BAYRAM    ##
#############################################################################################
## Sample call: ">> perl tb_gen [divisor] [bitlength]                                      ##
#############################################################################################



#!/usr/bin/perl
use POSIX;
use POSIX qw/floor/;
use warnings;
use strict;

use Scalar::Util qw(looks_like_number);



#****************************************************************************************
# -- SUBMODULE: bitWidth("arg.Number")
#*************************************************
# -- Returns the bitwidth that is required to represent the INTEGER PART of the
#    input argument
#****************************************************************************************                                                                          
sub bitwidth{

  if(floor($_[0]) == 0){
    return 1;
  }else{
    return ceil(log( floor($_[0]) + 1 ) / log(2)); 
  }

}                                                                 
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *




## Input Arguments Check ################################################################

if($#ARGV != 1){
  die "\nTESTBENCH GENERATION ERROR: Wrong number of input arguments.\n\n";
}elsif(looks_like_number($ARGV[0]) == 0 || looks_like_number($ARGV[1]) == 0){
  die "\nTESTBENCH GENERATION ERROR: Non-numeric input arguments.\n\n";
}elsif($ARGV[0] < 3){
  die "\nTESTBENCH GENERATION ERROR: Divisor cannot be less than 3.\n\n";
}elsif($ARGV[1] < 4){
  die "\nTESTBENCH GENERATION ERROR: Input Bitlength cannot be less than 4 bits.\n\n";
}elsif(floor($ARGV[0]) != $ARGV[0]){
  die "\nTESTBENCH GENERATION ERROR: Only integer values are allowed for divisor.\n\n";
}elsif(floor($ARGV[1]) != $ARGV[1]){
  die "\nTESTBENCH GENERATION ERROR: Bitlength must be an integer.\n\n";
}

######################################################### End of Input Arguments Check ##




## Set Values for Acquired Inputs #######################################################

my $divisor = $ARGV[0];
my $bit_len = $ARGV[1];

my $max_q_bitlen = bitwidth( ((2**$bit_len)-1) / $divisor );

my $max_r_bitlen;
if(bitwidth($divisor -1) > $bit_len){
  $max_r_bitlen = $bit_len;
}else{
  $max_r_bitlen = bitwidth( $divisor - 1 );
}

################################################ End of Set Values for Acquired Inputs ##




## Print the File #######################################################################

my $modulename = join('', ("tb_",$divisor,"N",$bit_len) );
my $dut_name   = join('',("divBy_$divisor","N",$bit_len));

open (MYFILE, ">$modulename.v");

if($bit_len < 19){

  print MYFILE "module $modulename\;\n\n";
  print MYFILE "\treg [",$bit_len-1,":0] data;\n";
  print MYFILE "\twire [",$max_q_bitlen-1,":0] q;\n";
  print MYFILE "\twire [",$max_r_bitlen-1,":0] r;\n";
  print MYFILE "\twire [",$bit_len-1,":0] testres;\n\n";
  
  print MYFILE $dut_name,"\nDUT_$dut_name (\n.q (q),\n.r (r),\n.addr (data)); \n\n";
  print MYFILE "initial begin
     data = 2;
     forever begin
	     #5
	    if(data==testres)begin
	        if(data==",(2**($bit_len))-1,")begin
	           \$display(\"1\");
	           \$finish;
	        end else
	        data=data+1;
	    end else begin
			  \$display(\"0\");
			  \$finish;
	    end
     end
  end\n";
	
}else{
	
  print MYFILE "module $modulename\;\n\n";
  print MYFILE "\treg [",$bit_len-1,":0] data;\n";
  print MYFILE "\treg [7:0] counter;\n";
  print MYFILE "\twire [",$max_q_bitlen-1,":0] q;\n";
  print MYFILE "\twire [",$max_r_bitlen-1,":0] r;\n";
  print MYFILE "\twire [",$bit_len-1,":0] testres;\n\n";
  
  print MYFILE $dut_name,"\nDUT_$dut_name (\n.q (q),\n.r (r),\n.addr (data)); \n\n";	
	print MYFILE "initial begin
     data = \$random;
     counter = 0;
     forever begin
	     #5
	    if(data==testres)begin
	        if(counter==255)begin
	           \$display(\"1\");
	           \$finish;
	        end else
	        data=\$random;
		    counter =counter+1;
	    end else begin
			  \$display(\"0\");
			  \$finish;
	    end
     end
  end\n";
	
}
 
print MYFILE "\nassign testres= (q*",$divisor,") + r;\n";
print MYFILE "\nendmodule";
close(MYFILE);

################################################################ End of Print the File ##












