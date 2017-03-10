#############################################################################################
##                                                                                         ##
##                 EFFICIENT COMBINATIONAL CIRCUITS FOR CONSTANT DIVISION                  ##
##			   ------- TABLE BASED DIVISION BY SMALL INTEGER CONSTANTS METHOD ----------       ##
##                                                                                         ##
#############################################################################################
##                                                                                         ##
##                                                                                         ##
##   Name          : gen.pl                                                                ##
##   Creation Date : 20.05.2013                                                            ##
##   Description   : Genrator for the method by Dinechin.                                  ##
##                                                                                         ##
##                                                                                         ##
##                                                                                         ##
##  Initial Placement :                                                        20.05.2013  ##
##                                                                            ANIL BAYRAM  ##
##                                                                                         ##                                                                    
#############################################################################################
## Sample call: ">> perl gen.pl [divisor] [bitlength] [alpha]                              ##
#############################################################################################


#!/usr/bin/perl
use POSIX;
use POSIX qw/floor/;
use warnings;
use strict;

use Scalar::Util qw(looks_like_number);



#****************************************************************************************
# -- SUBMODULE: dec2bin("arg.Decimal Number")
#********************************************
# -- Converts the decimal into its BINARY Representation.
#****************************************************************************************                                                                                     
sub dec2bin{                                                                                
	my $str = unpack("B32",pack("N",shift));
	$str =~ s/^0+(?=\d)//; #otherwise you will get leading zeros
	return $str;
}
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *




#****************************************************************************************
# -- SUBMODULE: addZ("arg.Total Required # of Bits","Binary number")
#*******************************************************************
# -- Pads zeros to the MSBs of the binary represented number
#****************************************************************************************
sub addZ{
	if($_[0] > length($_[1])){
		my @chars = split('',$_[1]);
		for(my $i=0 ; $i<($_[0]-length($_[1])) ; ++$i){
			unshift(@chars ,0);
		}
		my $done = join('',@chars);
		return $done;
	}
	elsif($_[0] == length($_[1])){
		return $_[1];
	}
	else{
# There should be an exception handler, but instead it just returns itself.
# Program should terminate here. There is obviously a problem if this part is executed..
		print "The supposed length is smaller,returning itself DINECHIN   ",$_[1],"\n";
		return $_[1];
	}
}
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *




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




# =======================================================================================
#  CHECK THE INPUT ARGUMENTS AND ASSIGN THE VARIABLES
# =======================================================================================

# Number of input arguments must be 3...........................................
if($#ARGV != 2){
  die "\nERROR 001: Number of input arguments do not hold\n\n",
      "           Arguments should be as:\n",
      "           Divisor - Input Dividend Bitlength - Alpha Constant\n\n" ;
}

# All inputs must be numeric ...................................................
for( my $ii = 0; $ii <= $#ARGV ; ++$ii){
  if(looks_like_number($ARGV[$ii]) == 0){
    die "\nERROR 002: All input arguments must be numeric.\n\n";
  }
}


# All input arguments must be an integer greater than 1 ........................
#for( my $ii = 0; $ii <= $#ARGV ; ++$ii){
#  if( (floor($ARGV[$ii]) != $ARGV[$ii]) || ($ARGV[$ii] <= 1) ){
#    die "\nERROR 003: All input arguments must be integers greater than 1.\n\n";
#  }
#}

# Divisor cannot be a power of 2 ...............................................
if( log($ARGV[0])/log(2) == floor(log($ARGV[0])/log(2)) ){
  die "\nERROR 004: Divisor cannot be a power of 2.\n\n";
}

# Alpha Should be Less than or Equal to the input bitlength ....................
if( $ARGV[1]<$ARGV[2]){
  die"\nERROR 005: Alpha must be less than or equal to the input ",
     "dividend bitlength.\n\n";
}


# Assign the input arguments to related constants:

my $divisor   = $ARGV[0];
my $x_len     = $ARGV[1];
my $alpha     = $ARGV[2];


my $xi_max    = (2**$alpha) - 1;

my $r_max     = $divisor - 1;

my $r_max_len;

if(bitwidth($r_max) > $x_len){
  $r_max_len = $x_len;
}else{
  $r_max_len = bitwidth( $r_max );
}

my $yi_max    = ($r_max * (2**$alpha)) + ((2**$alpha) - 1);
my $yi_len    = $alpha + $r_max_len;

my $qi_max     = floor($yi_max / $divisor);
my $qi_max_len = bitwidth( $qi_max );


#  CREATE FOLDER FOR THE FILES
# my $folder_name = join('', ("d_div_",$divisor,"N",$x_len));
# mkdir($folder_name);
# chdir($folder_name)|| die "Unable to change directory <$!>\n";


# =======================================================================================
#  CREATING THE BASE LOOK-UP TABLE
# =======================================================================================


my $modulename = join('',("divBy_$divisor","N","$x_len"));


# Open the file and start modifications .......................................

open (MYFILE, ">$modulename.v");

$modulename = join('',("d_lut_$divisor","N","$alpha"));

print MYFILE "module $modulename\(\n\n";
print MYFILE "\txi,\n\tri_p1,\n\tq,\n\tr);\n\n";

print MYFILE "input [",$alpha-1,":0] xi;\n";

if($r_max_len == 1){
  print MYFILE "input ri_p1;\n\n"; # This will never happen since the smallest remainder will be '2'
}else{
  print MYFILE "input [",$r_max_len-1,":0] ri_p1;\n\n";
}

if($qi_max_len == 1){
  print MYFILE "output q;\n";
}else{
  print MYFILE "output [",$qi_max_len-1,":0] q;\n";
}

if($r_max_len == 1){
  print MYFILE "output r;\n\n"; # This will never happen since the smallest remainder will be '2'
}else{
  print MYFILE "output [",$r_max_len-1,":0] r;\n\n";
}

print MYFILE "wire [",$yi_len -1,":0] yi;\n";
print MYFILE "reg  [",$qi_max_len + $r_max_len -1,":0] data;\n\n";

print MYFILE "always@(yi)\n\n";
print MYFILE "\tcasex(yi)\n\n";

for(my $ri_plus1 = 0; $ri_plus1 <= $r_max ; ++$ri_plus1){
  for (my $xi = 0; $xi <= $xi_max ; ++$xi){

    my $ri_plus1_bin = addZ($r_max_len,dec2bin($ri_plus1));

    my $xi_bin       = addZ($alpha,dec2bin($xi)); 
    
    my $yi           = ($ri_plus1 * (2**$alpha)) + $xi;
    my $qi           = floor( $yi/$divisor );
    my $ri           = $yi % $divisor;

    my $qi_bin       = addZ($qi_max_len,dec2bin($qi));
   
    my $ri_bin       = addZ($r_max_len,dec2bin($ri));   
    
    print MYFILE "\t\t",$yi_len,"'b",$ri_plus1_bin,$xi_bin," : data = ";
    print MYFILE $qi_max_len + $r_max_len,"'b",$qi_bin,$ri_bin,";\n";   
  
  
  }
}

print MYFILE "\n\t  default : data = ",$qi_max_len + $r_max_len,"'b";
for(my $ii=0 ; $ii< $qi_max_len + $r_max_len ; ++$ii){
	print MYFILE "x";
}      
print MYFILE ";\n";


print MYFILE "\n\tendcase\n\n";

print MYFILE "assign yi = {ri_p1,xi};\n";
print MYFILE "assign q  = data[",$qi_max_len + $r_max_len -1,":",$r_max_len,"];\n";

if($r_max_len == 1){
  print MYFILE "assign r  = data[0];\n";
}else{
  print MYFILE "assign r  = data[",$r_max_len -1,":0];\n";
}

print MYFILE "\nendmodule\n\n\n\n\n\n\n";
# close(MYFILE);


# =======================================================================================
#  CREATING THE TOP MODULE
# =======================================================================================


$modulename = join('',("divBy_$divisor","N","$x_len"));


my $q_max = floor( ((2**$x_len)-1)/$divisor );
my $q_max_len = bitwidth($q_max);
my $k = 0;
my $num_zero_pads_to_x = 0;
if( ($x_len % $alpha) != 0 ){
  $k = floor($x_len/$alpha) + 1;
  $num_zero_pads_to_x = $alpha - ($x_len % $alpha);
}else{
  $k = floor($x_len/$alpha);
}



# Open the file and start modifications .......................................


print MYFILE "module $modulename\(\n\n";
print MYFILE "\taddr,\n\tq,\n\tr);\n\n";

print MYFILE "input [",$x_len-1,":0] addr;\n";


if($q_max_len == 1){
  print MYFILE "output q;\n";
}else{
  print MYFILE "output [",$q_max_len-1,":0] q;\n";
}


if($r_max_len == 1){
  print MYFILE "output r;\n\n"; 
}else{
  print MYFILE "output [",$r_max_len-1,":0] r;\n\n";
}

print MYFILE "wire [",($k*$alpha)-1,":0] x_padded;\n";
print MYFILE "wire [",($k*$qi_max_len)-1,":0] q_conc;\n\n";


for(my $i = $k-1 ; $i >= 0 ; --$i){
  print MYFILE "wire [",$alpha-1,":0] chnk_$i;\n";
}

print MYFILE "\n";

if($qi_max_len == 1){
  for(my $i = $k-1 ; $i >= 0 ; --$i){
    print MYFILE "wire q$i\n;";
  }
}else{
  for(my $i = $k-1 ; $i >= 0 ; --$i){
    print MYFILE "wire [",$qi_max_len-1,":0] q$i;\n";
  }
}

print MYFILE "\n";

if($r_max_len == 1){
  for(my $i = $k ; $i >= 0 ; --$i){
    print MYFILE "wire r$i;\n";
  }
}else{
  for(my $i = $k ; $i >= 0 ; --$i){
    print MYFILE "wire [",$r_max_len-1,":0] r$i;\n";
  }
}

print MYFILE "\n\n";


$modulename = join('',("d_lut_$divisor","N","$alpha"));

for(my $i = $k-1 ; $i >= 0 ; --$i){
  print MYFILE "$modulename\n";
  print MYFILE "sb_$i","_","$modulename(\n";
  print MYFILE "\t.xi(chnk_$i),\n";
  print MYFILE "\t.ri_p1(r",$i +1,"),\n"; 
  print MYFILE "\t.q(q$i),\n"; 
  print MYFILE "\t.r(r$i)\n";
  print MYFILE ");\n\n"; 
}

print MYFILE "assign x_padded = {";
if($num_zero_pads_to_x > 0){
  print MYFILE $num_zero_pads_to_x,"'b";
  for(my $paddin = $num_zero_pads_to_x ; $paddin > 0 ; --$paddin ){
    print MYFILE "0";
  }
  print MYFILE ",";
}
print MYFILE "addr};\n";



for(my $i = $k-1 ; $i >= 0 ; --$i){
  print MYFILE "assign chnk_$i = x_padded[",(($i+1)*$alpha)-1,":",$i*$alpha,"];\n";
}

print MYFILE "assign r",$k," = 1'b0;\n";
print MYFILE "assign r = r0;\n";

print MYFILE "assign q_conc = {";
for(my $i = $k-1 ; $i >= 0 ; --$i){
  if($i == 0){
    print MYFILE "q$i";
  }else{
    print MYFILE "q$i,";
  }
}
print MYFILE "};\n";


if($q_max_len == 1){
  print MYFILE "assign q = q_conc[0];\n\n";
}else{
  print MYFILE "assign q = q_conc[",$q_max_len-1,":0];\n\n";
}

print MYFILE "\nendmodule\n\n";
close(MYFILE);



