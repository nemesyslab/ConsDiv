#############################################################################################
##                                                                                         ##
##                 EFFICIENT COMBINATIONAL CIRCUITS FOR CONSTANT DIVISION                  ##
##			                    ------- WRAPPER GENERATOR ----------                           ##
##                                                                                         ##
#############################################################################################
##                                                                                         ##
##   Name          : wrapper_gen.pl                                                        ##
##   Creation Date : 10.06.2013                                                            ##
##   Description   : Wrapper Generator for all methods.                                    ##
##                                                                                         ##
##                                                                                         ##
##                                                                                         ##
##                                                                       by ANIL BAYRAM    ##
#############################################################################################
## Sample call: ">> perl wrapper_gen [divisor] [bitlength]                                 ##
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



#****************************************************************************************
# -- SUBMODULE: signalDeclare(port_type , bit_width , signal_name )
#******************************************************************
# -- Signal port decleration in Verilog format
#****************************************************************************************                                                                          
sub signalDeclare{

  if($_[1] <= 1){
    print MYFILE "\t",$_[0]," ",$_[2],";\n";
  }else{
    print MYFILE "\t",$_[0]," ","[",$_[1]-1,":0] ",$_[2],";\n"
  }
return 0;
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

my $divisor = $ARGV[0];
my $bit_len = $ARGV[1];
######################################################### End of Input Arguments Check ##




## Set Values for Acquired Inputs #######################################################

my $max_q_bitlen = bitwidth( ((2**$bit_len)-1) / $divisor );

my $max_r_bitlen;
if(bitwidth($divisor -1) > $bit_len){
  $max_r_bitlen = $bit_len;
}else{
  $max_r_bitlen = bitwidth( $divisor - 1 );
}


my $modulename = join('', ("wrapper_",$divisor,"N",$bit_len) );
my $dut_name   = join('',("divBy_$divisor","N",$bit_len));

################################################ End of Set Values for Acquired Inputs ##




## Print the File #######################################################################

open (MYFILE, ">$modulename.v");

print MYFILE "module wrapper(clk,d_p,q_r,r_r);\n\n";

print MYFILE "\tinput clk;\n";

signalDeclare("input",$bit_len,"d_p");
signalDeclare("output",$max_q_bitlen,"q_r");
signalDeclare("output",$max_r_bitlen,"r_r");
print MYFILE "\n";

signalDeclare("reg",$bit_len,"d");
signalDeclare("reg",$max_q_bitlen,"q_r");
signalDeclare("reg",$max_r_bitlen,"r_r");
print MYFILE "\n";

signalDeclare("wire",$max_q_bitlen,"q");
signalDeclare("wire",$max_r_bitlen,"r");
print MYFILE "\n";

print MYFILE "\t","divByN","\n\tSB_$dut_name (\n\t\t.q (q),\n\t\t.r (r),\n",
             "\t\t.addr (d)\n\t); \n\n";

print MYFILE "\talways @ (posedge clk) begin\n";
print MYFILE "\t\td   <= d_p;\n";
print MYFILE "\t\tq_r <= q;\n";
print MYFILE "\t\tr_r <= r;\n";

print MYFILE "\tend\n\n";

print MYFILE "endmodule\n";

close(MYFILE);

################################################################ End of Print the File ##




