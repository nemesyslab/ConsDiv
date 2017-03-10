#############################################################################################
##                                                                                         ##
##                 EFFICIENT COMBINATIONAL CIRCUITS FOR CONSTANT DIVISION                  ##
##							   ------- LUT BASED DIVIDE AND CONQUER METHOD ----------                  ##
##                                                                                         ##
#############################################################################################
##                                                                                         ##
##                                                                                         ##
##   Name          : gen.pl                                                                ##
##   Creation Date : 02.03.2013                                                            ##
##   Description   : Genrator for the divide and conquer method.                           ##
##                                                                                         ##
##                                                                                         ##
##  Initial Placement :                                                        02.03.2013  ##
##                                                                            ANIL BAYRAM  ##
##                                                                                         ##                                                                    
#############################################################################################
## Sample call: ">> perl gen.pl [divisor] [dividend_bitlength] [initial_lutwidth]          ##
##                              [max_lutwidth] "                                           ##
#############################################################################################


#!/usr/bin/perl
use POSIX;
use POSIX qw/floor/;
use warnings;
use strict;

use Scalar::Util qw(looks_like_number);



#********************************************************************************************
# -- SUBMODULE: dec2bin("arg.Decimal Number")
#********************************************
# -- Converts the decimal into its BINARY Representation.
#********************************************************************************************                                                                                     
sub dec2bin{                                                                                
	my $str = unpack("B32",pack("N",shift));
	$str =~ s/^0+(?=\d)//; #otherwise you will get leading zeros
	return $str;
}
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * * * *




#********************************************************************************************
# -- SUBMODULE: bitWidth("arg.Number")
#*************************************************
# -- Returns the bitwidth that is required to represent the INTEGER PART of the
#    input argument
#********************************************************************************************                                                                          
sub bitwidth{
  if(floor($_[0]) == 0){
    return 1;
  }else{
    return ceil(log( floor($_[0]) + 1 ) / log(2)); 
  }
}                                                                 
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *




#********************************************************************************************
# -- SUBMODULE: signalDeclare(port_type , bit_width , signal_name )
#******************************************************************
# -- Signal port decleration in Verilog format
#********************************************************************************************                                                                          
sub signalDeclare{
  if($_[1] <= 1){
    print MYFILE "\t",$_[0]," ",$_[2],";\n";
  }else{
    print MYFILE "\t",$_[0]," ","[",$_[1]-1,":0] ",$_[2],";\n"
  }
return 0;
}                                                                 
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 




#********************************************************************************************
# -- SUBMODULE: addZ("arg.Total Required # of Bits","Binary number")
#*******************************************************************
# -- Pads zeros to the MSBs of the binary represented number
#********************************************************************************************
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
		print "The supposed length is smaller,returning itself    ",$_[1],"\n";
		return $_[1];
	}
}
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *




#********************************************************************************************
# -- SUBMODULE: initLutGen("divisor","Lut_Width")
#************************************************
# -- Pads zeros to the MSBs of the binary represented number
#********************************************************************************************

sub initLutGen{

  my $divisor       = $_[0]; # First Argument is the Divisor
  my $init_lutwidth = $_[1]; # Second Argument is the BitWidth
  my $file_name     = $_[2];
  
  my $modulename = join('', ("divBy_",$divisor,"N",$init_lutwidth));

  my $qu_len = bitwidth( ((2**$init_lutwidth)-1)/$divisor );

  my $rm_len;
  if(bitwidth($divisor -1) > $init_lutwidth){
    $rm_len = $init_lutwidth;
  }else{
    $rm_len = bitwidth( $divisor - 1 );
  }
  
                                
  open (MYFILE, ">>$file_name.v");
  print MYFILE "module $modulename\(\n\n";
  print MYFILE "\taddr,\n\tq,\n\tr);\n\n";
  
  if($init_lutwidth == 1){
    print MYFILE "\tinput addr;\n";
  }else{
    print MYFILE "\tinput [",$init_lutwidth-1,":0] addr;\n";
  }

  if($qu_len != 1){
    print MYFILE "\toutput [",$qu_len-1,":0] q;\n"; 
  }else{
    print MYFILE "\toutput q;\n";
  }

  if($rm_len != 1){
    print MYFILE "\toutput [",$rm_len-1,":0] r;\n\n";
  }else{
    print MYFILE "\toutput r;\n\n";
  }

  if($divisor >= (2**$init_lutwidth)){
  
    print MYFILE "assign q = 1'b0;\n";  
    print MYFILE "assign r = addr;\n";  
 
    print MYFILE "\nendmodule\n\n\n\n";
    close(MYFILE);
    
    return 0;
  
  }else{

    print MYFILE "\treg [",$qu_len + $rm_len-1,":0] data;\n\n";
    print MYFILE "always@(addr)\n\n";
    print MYFILE "\tcasex(addr)\n\n";

    for(my $i=0 ; $i<(2**$init_lutwidth) ; ++$i){
	    my $tmp_q = floor($i / $divisor);
	    my $tmp_r = $i % $divisor;
	    my $dataq = addZ($qu_len,dec2bin($tmp_q));
	    my $datar = addZ($rm_len,dec2bin($tmp_r));
	    my $addr  = addZ($init_lutwidth,dec2bin($i));
	    print MYFILE "\t\t",$init_lutwidth,"'b",$addr,": data = ",$qu_len+$rm_len,"'b",
	                       $dataq,$datar,";\n";
    }
    
    
    print MYFILE "\n\t  default: data = ",$qu_len+$rm_len,"'b";
    for(my $ii=0 ; $ii< $qu_len+$rm_len ; ++$ii){
	    print MYFILE "x";
    }      
    print MYFILE ";\n";
    
    
    
    
    
    
    print MYFILE "\n\tendcase\n\n";
    
    if($qu_len +$rm_len-1 == $rm_len){
      print MYFILE "assign q = data[",$rm_len,"];\n";  
    }else{
      print MYFILE "assign q = data[",$qu_len +$rm_len-1,":",$rm_len,"];\n";  
    }
    
    if($rm_len == 1){
      print MYFILE "assign r = data[0];\n";
    }else{
      print MYFILE "assign r = data[",$rm_len-1,":0];\n";
    }

    print MYFILE "\nendmodule\n\n\n\n";
    close(MYFILE);
    
    return (2**$init_lutwidth) * ($qu_len + $rm_len);
  }
  
}

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *




#********************************************************************************************
# -- SUBMODULE: transLutGen("divisor",bitwidths of LUTS to be compiled in order)
#*******************************************************************************
# -- 
#********************************************************************************************                                                                                 
sub transLutGen{

  # Error Check # ----------------------------------------------------------------------
  
  if($#_ != 3){ ## Only 2 LUTs must be combined
    die "\nERROR in transLUT generation. Invalid number of arguments\n\n";
  }
  
  # Calculating variables to be used in the generation # -------------------------------
  
  my $divisor        = $_[0];
  my $parentLutLeft  = $_[1];
  my $parentLutRight = $_[2]; 
  my $outLut_width   = $parentLutLeft + $parentLutRight;
  
  my $file_name      = $_[3];
  
  # Remainder Left Bitwidth
  my $rmLeft_len;
  my $rmLeft_max;
  if(bitwidth($divisor -1) > $parentLutLeft){
    $rmLeft_len = $parentLutLeft;
    $rmLeft_max = (2**($parentLutLeft)) - 1;
  }else{
    $rmLeft_len = bitwidth( $divisor - 1 );
    $rmLeft_max = $divisor - 1;
  }

  # Remainder Right Bitwidth
  my $rmRight_len;
  my $rmRight_max;  
  if(bitwidth($divisor -1) > $parentLutRight){
    $rmRight_len = $parentLutRight;
    $rmRight_max = (2**($parentLutRight)) - 1;
  }else{
    $rmRight_len = bitwidth( $divisor - 1 );
    $rmRight_max = $divisor - 1;
  }
  
  # Output Remainder Bitwidth
  my $rm_len;
  if(bitwidth($divisor -1) > $parentLutRight + $parentLutLeft){
    $rm_len = $parentLutRight + $parentLutLeft;
  }else{
    $rm_len = bitwidth( $divisor - 1 );
  }
  
  my $out_q3_len = floor((($rmLeft_max*(2**$parentLutRight))+$rmRight_max)/$divisor);
     $out_q3_len = bitwidth( $out_q3_len );
  
  my $modulename = join('',("trans",$parentLutLeft,"and",$parentLutRight));
     $modulename = join('',($modulename,"_",$divisor,"N",$outLut_width));
     
     
     
  
  # Open file and Start Filling it 
  open (MYFILE, ">>$file_name.v");
  print MYFILE "module $modulename\(\n\n";
  print MYFILE "\tr1,\n\tr2,\n\tq3,\n\tr);\n\n";
  
  
  if($rmLeft_len == 1){
    print MYFILE "\tinput  r1;\n";
  }else{
    print MYFILE "\tinput  [",$rmLeft_len-1,":0] r1;\n";
  }
  
  if($rmRight_len == 1){
    print MYFILE "\tinput  r2;\n";
  }else{
    print MYFILE "\tinput  [",$rmRight_len-1,":0] r2;\n";
  }
  
  if($out_q3_len == 1){
    print MYFILE "\toutput q3;\n";
  }else{
    print MYFILE "\toutput [",$out_q3_len-1,":0] q3;\n";
  }
  
  if($rm_len == 1){
    print MYFILE "\toutput r;\n\n";
  }else{
    print MYFILE "\toutput [",$rm_len-1,":0] r;\n\n";
  }
  
	print MYFILE "\twire [",$rmLeft_len + $rmRight_len-1,":0] addr;\n",
	             "\treg  [",$rm_len + $out_q3_len-1,":0] data;\n\n";
	             
	print MYFILE "always@(addr)\n\n";
	print MYFILE "\tcasex(addr)\n\n";               
               
  for(my $i1=0 ; $i1<=$rmLeft_max ; ++$i1){
    for(my $i2=0 ; $i2<=$rmRight_max ; ++$i2){
	    my $tmp_q = floor((( $i1 * (2**$parentLutRight) ) + $i2) / $divisor);
	    my $tmp_r = (( $i1 * (2**$parentLutRight) ) + $i2) % $divisor;
	    my $dataq = addZ($out_q3_len,dec2bin($tmp_q));
	    my $datar = addZ($rm_len,dec2bin($tmp_r));
	    my $addr1 = addZ($rmLeft_len,dec2bin($i1));
	    my $addr2 = addZ($rmRight_len,dec2bin($i2));
	    my $addr = join('',($addr1,$addr2));
	    print MYFILE "\t  ",$rmRight_len + $rmLeft_len,"'b",$addr,": data = ",
	                        $out_q3_len + $rm_len,"'b",$dataq,$datar,";\n";
    }	
	}
      
      
	print MYFILE "\n\t  default: data = ",$out_q3_len + $rm_len,"'b";
	for(my $ii=0 ; $ii<$out_q3_len +$rm_len ; ++$ii){
		print MYFILE "x";
	}      
	print MYFILE ";\n";
	print MYFILE "\n\tendcase\n\n";
	
	if($out_q3_len +$rm_len-1 == $rm_len){
	  print MYFILE "assign q3 = data[",$rm_len,"];\n";
	}else{
	  print MYFILE "assign q3 = data[",$out_q3_len +$rm_len-1,":",$rm_len,"];\n";
	}
	
	if($rm_len == 1){
		print MYFILE "assign r  = data[0];\n";
	}else{
	  print MYFILE "assign r  = data[",$rm_len-1,":0];\n";
	}

	print MYFILE "assign addr = {r1,r2};\n";
	print MYFILE "\nendmodule\n\n\n\n";
	close(MYFILE);               
               
  # -----------------------------------------------------------------
  # Generation of the Combined LUT
  # -----------------------------------------------------------------             
  
  $modulename     = join('', ("divBy_",$divisor,"N",$outLut_width));
  my $comb_q_len  = bitwidth( ((2**$outLut_width)-1) / $divisor );
  
  my $q_Left_len  = bitwidth( ((2**$parentLutLeft) -1)/$divisor );
  my $q_Right_len = bitwidth( ((2**$parentLutRight)-1)/$divisor );  
    
        
  # Open File and Start Filling it
  open (MYFILE, ">>$file_name.v");
  print MYFILE "module $modulename\(\n\n";
  print MYFILE "\taddr,\n\tq,\n\tr);\n\n";
  
	print MYFILE "\tinput  [",$outLut_width -1,":0] addr;\n";
	

	if($comb_q_len == 1){
	  print MYFILE	"\toutput q;\n";
	}else{
	  print MYFILE  "\toutput [",($comb_q_len)-1,":0] q;\n";
	}
	
		
	if($rm_len == 1){
	  print MYFILE	"\toutput r;\n\n";
	}else{
	  print MYFILE  "\toutput [",$rm_len-1,":0] r;\n\n";
	}	
	
	
	if($q_Left_len == 1){
    print MYFILE "\twire q1;\n";
  }else{
    print MYFILE "\twire [",$q_Left_len -1,":0] q1;\n";
  }
  
	if($q_Right_len == 1){
    print MYFILE "\twire q2;\n";
  }else{
    print MYFILE "\twire [",$q_Right_len -1,":0] q2;\n";
  }
  
	if($out_q3_len == 1){
    print MYFILE "\twire q3;\n";
  }else{
    print MYFILE "\twire [",$out_q3_len -1,":0] q3;\n";
  }  

  if($rmLeft_len == 1){
    print MYFILE "\twire r1;\n";
  }else{
    print MYFILE "\twire [",$rmLeft_len-1,":0] r1;\n";
  }

  if($rmRight_len == 1){
    print MYFILE "\twire r2;\n";
  }else{
    print MYFILE "\twire [",$rmRight_len-1,":0] r2;\n";
  }         
  
  if($parentLutLeft == 1){
    print MYFILE "\twire addr1;\n";
  }else{
    print MYFILE "\twire [",$parentLutLeft - 1,":0] addr1;\n";
  }

  if($parentLutRight == 1){
    print MYFILE "\twire addr2;\n";
  }else{
    print MYFILE "\twire [",$parentLutRight - 1,":0] addr2;\n";
  }  
  
  
  ## Instantiation of the previout Luts and the transfer Lut.
  
  my $inst_count = 0;
  
  print MYFILE "\n\n divBy_", $divisor , "N", $parentLutLeft , 
               "  d", $divisor , "N", $parentLutLeft , "_", $inst_count,"(\n";
  print MYFILE "\t.addr(addr1),\n\t.q(q1),\n\t.r(r1));\n\n"; 
  
  if($parentLutLeft == $parentLutRight){
    $inst_count = $inst_count + 1;
  }
  
  print MYFILE "\n\n divBy_", $divisor , "N", $parentLutRight , 
               "  d", $divisor , "N", $parentLutRight , "_", $inst_count,"(\n";
  print MYFILE "\t.addr(addr2),\n\t.q(q2),\n\t.r(r2));\n\n";  
  
  
  
  print MYFILE "\n\n trans", $parentLutLeft , "and", $parentLutRight , "_", 
                $divisor , "N", $parentLutRight + $parentLutLeft , "  d",$divisor,"N",
                $parentLutRight + $parentLutLeft ,"trans(\n";
  print MYFILE ".r1(r1),\n.r2(r2),\n.q3(q3),\n.r(r) );\n\n";
  
  if($outLut_width-1 ==$parentLutRight){
    print MYFILE "\tassign addr1 = addr[",$outLut_width-1,"];\n";
  }else{
    print MYFILE "\tassign addr1 = addr[",$outLut_width-1,":",$parentLutRight,"];\n";
  }

  if($parentLutRight -1 == 0){
    print MYFILE "\tassign addr2 = addr[0];\n";
  }else{
  	print MYFILE "\tassign addr2 = addr[",$parentLutRight-1,":0];\n";
  }

	print MYFILE "\tassign q = (q1<<",$parentLutRight,") + q2 + q3;\n\n";
	print MYFILE "\nendmodule\n\n\n\n";
  
  
               
  close(MYFILE);             
               
      
  # Returns the size of the Transfer LUT That is Genrated             
  return ($out_q3_len + $rm_len) * ($rmRight_max + 1) * ($rmLeft_max + 1);               
}
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *








# =======================================================================================
#  CHECK THE INPUT ARGUMENTS AND ASSIGN THEM
# =======================================================================================

 my $divisor;
 my $inp_bitlen;
 
 my $init_lutwidth;
 my $max_init_lutwidth;

 my $file_name;

 # ---------------------------------------------------------------------------------
 if($#ARGV == 1){ 
 # ( Divisor - Input Bitlength )
 # ---------------------------------------------------------------------------------

   # Validity Check 
   if(looks_like_number($ARGV[0]) == 0 || looks_like_number($ARGV[1]) == 0){
     die "\nERROR 001 : Non-numeric input arguments.\n\n"; 
   }
   
   # Divisor Numerical Analysis
   if($ARGV[0] < 2 || floor($ARGV[0])!= $ARGV[0]){
	   die "\nERROR 002 : Divisor MUST BE a positive integer greater than '1'.\n\n";
	 }
	 
	 # Dividend Bitlength Numerical Analysis
	 if($ARGV[1] < 4 || floor($ARGV[1])!= $ARGV[1]) {
     die "\nERROR 003 : Invalid Dividend Bitlength Argument;\n",
         "only positive integers greater than ", 3 ," are allowed.\n\n";
   }
    
   # ASSIGNMENTS #
   

   $divisor           = $ARGV[0];
   $inp_bitlen        = $ARGV[1];
   $init_lutwidth     = 4;
   $max_init_lutwidth = $init_lutwidth;
    
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
 
 # ---------------------------------------------------------------------------------
 }elsif($#ARGV == 2){
   # (Divisor - Input Bitlength - Initial Lut Width)
 # ---------------------------------------------------------------------------------

     # Validity Check 
     if(looks_like_number($ARGV[0]) == 0 || looks_like_number($ARGV[1]) == 0 || 
        looks_like_number($ARGV[2]) == 0){
       die "\nERROR 007 : Non-numeric input arguments.\n\n"; 
     }
     
     # Divisor Numerical Analysis
     if($ARGV[0] < 2 || floor($ARGV[0])!= $ARGV[0]){
	     die "\nERROR 008 : Divisor MUST BE a positive integer other than '1'.\n\n";
	   }
	   
	   # Dividend Bitlength Numerical Analysis
	   if($ARGV[1] < $ARGV[2] || floor($ARGV[1])!= $ARGV[1]) {
       die "\nERROR 009 : Invalid Dividend Bitlength Argument: ",
           "Only positive integers\n\t    greater than or equal to the Initial ", 
           "Lut Width (",$ARGV[2],") are allowed.\n\n";
     }   
     
     # Initial Lut Width Numerical Analysis
     if($ARGV[2] < 2 || floor($ARGV[2])!= $ARGV[2]){
       die "\nERROR 010 : Initial Lut Width must be an integer greater than '1'.\n\n";
     }
      
     # ASSIGNMENTS #
      
     $divisor           = $ARGV[0];
     $inp_bitlen        = $ARGV[1];
     $init_lutwidth     = $ARGV[2];
     $max_init_lutwidth = $init_lutwidth;
	      
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 
 
 # ---------------------------------------------------------------------------------
 }elsif($#ARGV == 3){
   # ( Divisor - Input Bitlength - Initial Lut Width - Max Initial Lut Width)
 # ---------------------------------------------------------------------------------

     # Validity Check 
     if(looks_like_number($ARGV[0]) == 0 || looks_like_number($ARGV[1]) == 0 || 
        looks_like_number($ARGV[2]) == 0 || looks_like_number($ARGV[3]) == 0 ){
       die "\nERROR 015 : Non-numeric input arguments.\n\n"; 
     }
     
     # Divisor Numerical Analysis
     if($ARGV[0] < 2 || floor($ARGV[0])!= $ARGV[0]){
	     die "\nERROR 016 : Divisor MUST BE a positive integer other than '1'.\n\n";
	   }
	   
	   # Dividend Bitlength Numerical Analysis
	   if($ARGV[1] < $ARGV[2] || floor($ARGV[1])!= $ARGV[1]) {
       die "\nERROR 017 : Invalid Dividend Bitlength Argument: ",
           "Only positive integers\n\t    greater than or equal to the Initial ", 
           "Lut Width (",$ARGV[2],") are allowed.\n\n";
     }   
     
     # Initial Lut Width Numerical Analysis
     if($ARGV[2] < 2 || floor($ARGV[2])!= $ARGV[2]){
       die "\nERROR 018 : Initial Lut Width must be an integer greater than '1'.\n\n";
     }
     
     # Max Initial Lut Width Numerical Analysis
     if($ARGV[3] < $ARGV[2] || floor($ARGV[3])!= $ARGV[3]){
       die "\nERROR 019 : Maximum Initial Lut Width cannot be less than the",
           " initial Lut Width\n\n";
     }
     
      
     # ASSIGNMENTS #
      
     $divisor           = $ARGV[0];
     $inp_bitlen        = $ARGV[1];
     $init_lutwidth     = $ARGV[2];
     $max_init_lutwidth = $ARGV[3]; 
   
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 
 
 # ---------------------------------------------------------------------------------
 }else{
 # There is no such combination of input arguments and this is an error.
   die "\nERROR 026 : Invalid number of input arguments.\n\n";
 }
 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 



$file_name = join('',"divBy_",$divisor,"N",$inp_bitlen) ||
              die ("ERROR: Cannot create filename gen.pl 630\n\n");
system("rm -r -f $file_name.v");




# =================================================================================================
#  CALCULATES INITIAL LUT SIZES 
# =================================================================================================
#  \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ 
 
 
 # Variables that will be acquired #
 my @init_lut_sizes_arr; 
 # - - - - - - - - - - - - - - - - #
 
 
 # Optimize the remaining ungrouped bits if possible 
 
 my $remaining_bits = $inp_bitlen % $init_lutwidth;
 my $num_initial_luts = floor($inp_bitlen / $init_lutwidth);
  

 # Level Optimization Constraints:
 # 1- There must be some remaining ungrouped bits
 # 2- Max Initial Lut Width must be greater than the İnitial Lut Width
 # 3- Number of initial Luts must be an even number so that the optimization
 #    will improve timing. Otherwise we will just have worse area with the
 #    same timings
 # 4- The Maximum lutwidth constraint must not be exceeded for any intial
 #    Lut after optimization.
 
 my $max_lut_size_after_opt =
    $init_lutwidth + ($remaining_bits / $num_initial_luts);
 
 
 # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 if(  ($remaining_bits != 0)                                  &&
      ($max_init_lutwidth > $init_lutwidth)                   &&
      ($num_initial_luts % 2 == 0 || $num_initial_luts == 1)  &&
      ($max_lut_size_after_opt <= $max_init_lutwidth)     ) {

   # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   for(my $i = 0; $i < $num_initial_luts; ++$i){
   
     if($i < $num_initial_luts - ($remaining_bits % $num_initial_luts)){
       $init_lut_sizes_arr[$i] = $init_lutwidth + floor($remaining_bits / $num_initial_luts);    
     }else{
       $init_lut_sizes_arr[$i] = $init_lutwidth + floor($remaining_bits / $num_initial_luts) +1;
     }

   }  
   # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 }else{

   # - - - - - - - - - - - - - - - - - - - - - - - - - 
   for (my $i = 0; $i < $num_initial_luts + 1 ; ++$i){

     if($i < $num_initial_luts){
       $init_lut_sizes_arr[$i] = $init_lutwidth;
     }elsif($remaining_bits != 0){
       $init_lut_sizes_arr[$i] = $remaining_bits;
     }

   }
   # - - - - - - - - - - - - - - - - - - - - - - - - - 
   
   if($remaining_bits != 0){
     $num_initial_luts = ++$num_initial_luts;
   }
 
 }
 # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
   
   
#  /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ 
# =================================================================================================
#                                                              E N D - CALCULATES INITIAL LUT SIZES
# =================================================================================================





# =================================================================================================
#  GENERATE THE 2-D LUT ARRAY WITH LUTS AT EACH LEVEL
# =================================================================================================
#  \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ 

my @prev_luts = @init_lut_sizes_arr;

my @level_luts_arr;
push @level_luts_arr,[@prev_luts];


my @tmp_lut;

my $transLeft_p = 0;
my $transRight_p = 0;
my $curr_trans_Lutsize = 0;
my $transLutSize = 0;
my $rLUTnum=0;
my @rLUTs;
my $max;
my $level;
if($num_initial_luts > 1){

  for (my $level_no = 1 ; $level_no <= ceil(log($num_initial_luts)/log(2)) ; ++$level_no){

    my $index = 0;
    
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    for(my $i = 0; $i < ceil(($#prev_luts+1)/2); ++$i){

      if($#prev_luts == $index){
        $tmp_lut[$i] = $prev_luts[$index] ;  
      }else{   
        $tmp_lut[$i] = $prev_luts[$index]+ $prev_luts[$index + 1];   
        
        if($transLeft_p != $prev_luts[$index] || $transRight_p != $prev_luts[$index + 1]){
		$max = $prev_luts[$index] > $prev_luts[$index + 1] ? $prev_luts[$index] : $prev_luts[$index + 1];
		if($max<=$init_lutwidth){
			$level=$max<bitwidth($divisor) ? 1 : 2;
		}
		else{
			for(my $i=0;$i<$rLUTnum;$i++){
				if(index(substr($rLUTs[$i], index($rLUTs[$i], "-" )+1 , index($rLUTs[$i], ":" )-index($rLUTs[$i], "-" )-1), $max)!=-1){
					$level=(substr($rLUTs[$i],0,index($rLUTs[$i], "-"))+1);
				}
			}
		}
        	$rLUTs[$rLUTnum] = $level . "-" . ($prev_luts[$index] + $prev_luts[$index + 1]) . ":" . $prev_luts[$index] . "+" . $prev_luts[$index + 1] . "\n";
		$rLUTnum++;
          #$curr_trans_Lutsize =  transLutGen($divisor, $prev_luts[$index], $prev_luts[$index + 1],$file_name);
          $transLutSize = $transLutSize + $curr_trans_Lutsize  ;
          
        }else{
        
          $transLutSize = $transLutSize + $curr_trans_Lutsize  ;
        
        }
        
        $transLeft_p  = $prev_luts[$index];
        $transRight_p = $prev_luts[$index + 1];        
             
      }
      $index = $index + 2;
    
    }
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    
    @prev_luts = @tmp_lut;
    @tmp_lut = 0;
    
    push @level_luts_arr,[@prev_luts];
    
  }

}

 my $logname  = join('', ("log_",$divisor,"N",$inp_bitlen));
 open (GEN_LOGFILE, ">$logname");



 print GEN_LOGFILE "*********************************************\n";
 print GEN_LOGFILE "DESIGN FLOW TREE for $divisor N $inp_bitlen \n";
 print GEN_LOGFILE "@$_\n" for @level_luts_arr;
 print GEN_LOGFILE "*********************************************";
#  /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ 
# =================================================================================================
#                                      E N D  -  GENERATE THE 2-D LUT ARRAY WITH LUTS AT EACH LEVEL
# =================================================================================================



# =================================================================================================
#  GENERATE THE INITIAL ARRAYS AND CALCULATE TOTAL SIZE
# =================================================================================================
#  \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ 

#print $#{ $level_luts_arr[0] },"\n";

 my $prev_init_lut = 0;
 my $prev_init_lut_size = 0;
 my $total_init_lut_size = 0;
 my $iLUTnum=0;
my @iLUTs;
 for(my $i1 = 0; $i1 <= $#{ $level_luts_arr[0] } ; ++$i1){
   
   if($level_luts_arr[0][$i1] == $prev_init_lut){
   
     $total_init_lut_size = $total_init_lut_size + $prev_init_lut_size;
   
   }else{
   		if($level_luts_arr[0][$i1]<bitwidth($divisor)){
			$level=0;
		}
		else{
			$level=1;
		}
        	$iLUTs[$iLUTnum] = $level . "-" . $level_luts_arr[0][$i1] . ":" . $level_luts_arr[0][$i1] . "\n";
		$iLUTnum++;
     $prev_init_lut = $level_luts_arr[0][$i1];
     #$prev_init_lut_size  = initLutGen($divisor,$level_luts_arr[0][$i1],$file_name);
     $total_init_lut_size = $total_init_lut_size + $prev_init_lut_size;
   
   }
 
 
 }

 #print $total_init_lut_size,"\n";

#  /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ 
# =================================================================================================
#                                      E N D - GENERATE THE INITIAL ARRAYS AND CALCULATE TOTAL SIZE
# =================================================================================================

my $total_size = $total_init_lut_size + $transLutSize;



print GEN_LOGFILE "\nTotal # of stored bits are : $total_size";
print GEN_LOGFILE "\n*********************************************\n";
close(GEN_LOGFILE);


open (partFP, ">areaPartitioning");

for(my $i=0; $i<$iLUTnum; $i++){
	print partFP $iLUTs[$i];
}
for(my $i=0; $i<$rLUTnum; $i++){
	print partFP $rLUTs[$i];
}

close(partFP);	

































