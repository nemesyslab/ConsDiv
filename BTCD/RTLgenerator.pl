#!/usr/bin/perl

use POSIX;

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
		    if ( ($parentLutRight + bitwidth($divisor -1) ) < 38) {
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
		    else{
			    my $q1 = floor(( $i1 * (2**32) ) / $divisor);
			    my $r1 = ( $i1 * (2**32) ) % $divisor;
			    my $q2 = floor((( ($r1 * (2**($parentLutRight - 32)) ) ) + $i2) / $divisor);
			    my $r2 = (( ($r1 * (2**($parentLutRight - 32)) ) ) + $i2) % $divisor;
			    $q1 = ($q2 >= 2**($parentLutRight - 32)) ? ($q1 + 1) : $q1;
			    $q2 = ($q2 >= 2**($parentLutRight - 32)) ? ($q2 - 2**($parentLutRight - 32)) : $q2;
		    	    #my $tmp_q = $tmp1_q + $tmp2_q;
			    #my $dataq1 = addZ(48,dec2bin($q1));
			    #my $dataq2 = addZ($out_q3_len-48,dec2bin($q2));
			    my $datar = addZ($rm_len,dec2bin($r2));
			    my $addr1 = addZ($rmLeft_len,dec2bin($i1));
			    my $addr2 = addZ($rmRight_len,dec2bin($i2));
			    my $addr = join('',($addr1,$addr2));
			    print MYFILE "\t  ",$rmRight_len + $rmLeft_len,"'b",$addr,": data = ";
			    printf MYFILE "{%d'h%x, %d'h%x, %d'h%x};\n", 32, $q1, ($parentLutRight - 32), $q2, $rm_len, $r2 ;
			    #((($q1 << 48) + $q2) << $rm_len )
			    #printf MYFILE "'h%x;\n", ((($q1 << 48) + $q2) << $rm_len ) + $r2 ;
		    }
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
#******************************************************************************************** 

$num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nUsage: perl estimator.pl divisor partitionFileName\n";
    print "\nExample Partition File Format\n";
    print "3:3
4:4
7:4+3
6:3+3
9:6+3
16:9+7  => should be highest level at the last line\n";
    exit;
}

$divisor=$ARGV[0];
$inputFileName=$ARGV[1];

open(inputFP, "<$inputFileName") or die "Couldn't open input file $inputFileName, $!";

$rLUTnum=0;
$iLUTnum=0;
while(<inputFP>){
	if(eof){
		$topLevel=substr($_, 0, index($_,":"));
		$creation[$topLevel]=substr($_, index($_,":")+1, index($_, "\n")-index($_,":")-1 );
	}
	elsif(index($_, "+")!=-1){
		$rLUTs[$rLUTnum]=substr($_, 0, index($_, ":") );
		$creation[$rLUTs[$rLUTnum]]=substr($_, index($_,":")+1, index($_, "\n")-index($_,":")-1 );
		$rLUTnum++;
	}else{
		$iLUTs[$iLUTnum]=substr($_, 0, index($_, ":") );
		$creation[$iLUTs[$iLUTnum]]=substr($_, index($_,":")+1, index($_, "\n")-index($_,":")-1 );
		$iLUTnum++;
	}

}
close(inputFP);
##TEST Partitioning
#for (my $i=0;$i<$iLUTnum;$i++){
#	print $iLUTs[$i] . ":" . $creation[$iLUTs[$i]] . "\n";
#}
#for (my $i=0;$i<$rLUTnum;$i++){
#	$left=substr($creation[$rLUTs[$i]], 0, index($creation[$rLUTs[$i]], "+"));
#	$right=substr($creation[$rLUTs[$i]], index($creation[$rLUTs[$i]], "+")+1);
#	print $rLUTs[$i] . ":" . $left . "+" . $right . "\n";
#}
#if($topLevel!=0){
#	$left=substr($creation[$topLevel], 0, index($creation[$topLevel], "+"));
#	$right=substr($creation[$topLevel], index($creation[$topLevel], "+")+1);
#	print $topLevel . ":" . $left . "+" . $right . "\n";
#}

$bitSize=$topLevel;

$file_name = join('',"divBy_",$divisor,"N",$bitSize) || die ("ERROR: Cannot create filename gen.pl 630\n\n");
system("rm -r -f $file_name.v");

# Create RTL
for (my $i=0;$i<$iLUTnum;$i++){
	initLutGen($divisor,$iLUTs[$i],$file_name);
}
for (my $i=0;$i<$rLUTnum;$i++){
	$left=substr($creation[$rLUTs[$i]], 0, index($creation[$rLUTs[$i]], "+"));
	$right=substr($creation[$rLUTs[$i]], index($creation[$rLUTs[$i]], "+")+1);
	transLutGen($divisor, $left, $right,$file_name);
}
if($topLevel!=0){
	$left=substr($creation[$topLevel], 0, index($creation[$topLevel], "+"));
	$right=substr($creation[$topLevel], index($creation[$topLevel], "+")+1);
	transLutGen($divisor, $left, $right,$file_name);
}

