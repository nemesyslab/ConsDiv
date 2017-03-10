#############################################################################################
##                                                                                         ##
##                 EFFICIENT COMBINATIONAL CIRCUITS FOR CONSTANT DIVISION                  ##
##			                  ------- GENERATION COORDINATOR ----------                        ##
##                                                                                         ##
#############################################################################################
##                                                                                         ##
##                                                                                         ##
##   Name          : generate.pl                                                           ##
##   Creation Date : 17.06.2013                                                            ##
##   Description   : Calls generators for a given range of divisors and bitlengths.        ##
##                   Invokes the generators for testBenches and Wrappers.                  ##
##                                                                                         ##
##                                                                                         ##
##                                                                                         ##
##  Initial Placement :                                                        17.06.2013  ##
##                                                                            ANIL BAYRAM  ##
##                                                                                         ##                                                                    
#############################################################################################
## Sample call: ">> perl generate.pl [min_divisor] [max_divisor] [min_bitlength]           ##
##                                   [max_bitlength] [k_value]   [PartitionType]           ##
#############################################################################################


#!/usr/bin/perl
use POSIX;
use POSIX qw/floor/;
use warnings;
use strict;
use Cwd;

use Scalar::Util qw(looks_like_number);


sub is_power_of_2 {
  return 0 unless $_[0]>0; # to avoid log error
  log($_[0])/log(2) - int(log($_[0])/log(2)) ? 0 : 1 
}

# =======================================================================================
#  CHECK THE INPUT ARGUMENTS
# =======================================================================================

# Number of input arguments must be 4...........................................
if($#ARGV != 5){
  die "\nERROR 001: Number of input arguments do not hold\n\n",
      "           Arguments should be as:\n",
      "           Min_Divisor - Max_Divisor - Min_BitLength - Max_BitLength - k_value - Area(0)_or_Time(1)\n\n" ;
}

# All inputs must be numeric ...................................................
for( my $ii = 0; $ii <= $#ARGV ; ++$ii){
  if(looks_like_number($ARGV[$ii]) == 0){
    die "\nERROR 002: All input arguments must be numeric.\n\n";
  }
}


# All input arguments must be an integer greater than 1 ........................
for( my $ii = 0; $ii <= $#ARGV-2 ; ++$ii){
  if( (floor($ARGV[$ii]) != $ARGV[$ii]) || ($ARGV[$ii] <= 2) ){
    die "\nERROR 003: All input arguments must be integers greater than 2.\n\n";
  }
}

## Assign the Input Arguments ###########################################################

my $min_divisor = $ARGV[0];
my $max_divisor = $ARGV[1];
my $min_bitlen  = $ARGV[2];
my $max_bitlen  = $ARGV[3];
my $k  = $ARGV[4];
my $partitionBase  = $ARGV[5];

#################################################### End of Assign the Input Arguments ##




## Divide and Conquer Files Generation ##################################################


## We are in the ecc_for_cd/gen/sandbox folder. The output of divConq method will be placed
## in ecc_for_cd/gen/verilog/divConq folder. So we jump to there

my $pwd =cwd(); # This is where we are.


for(my $dvsr = $min_divisor ; $dvsr <= $max_divisor ; ++$dvsr){
  for(my $bl = $min_bitlen ; $bl <= $max_bitlen ; ++$bl){
  
    if(is_power_of_2($dvsr) == 0){
      if ( (2**$bl) > $dvsr ) {
    
        system("/usr/bin/perl gen.pl $dvsr $bl $k");
	if($partitionBase==0){
		system("/usr/bin/perl .RTLgenerator.pl $dvsr areaPartitioning");   
	}
	else{
		system("/usr/bin/perl RTLgenerator.pl $dvsr timePartitioning");   
	}
#        system("/usr/bin/perl .tb_gen.pl $dvsr $bl");
#        system("/usr/bin/perl wrapper_gen.pl $dvsr $bl");
      
      }  
    }
  
  
  }
}


