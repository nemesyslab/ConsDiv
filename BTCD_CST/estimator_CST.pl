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


$num_args = $#ARGV + 1;
if ($num_args != 5) {
    print "\nUsage: perl estimator.pl bitSize divisor rate force_partition prints(enter number between 0-3, first bit 1 for tree, second bit 1 for print calculations)\n";
    exit;
}

$rate=$ARGV[2];
$forcePartition=$ARGV[3];
$prints=$ARGV[4];
$bitSize=$ARGV[0];
$divisor=$ARGV[1];
$divisorBitSize=bitwidth($divisor);

for(my $currentBitSize=1; $currentBitSize<=$bitSize ; $currentBitSize++){ #Find minimum size for all bit sizes till given bit size.

	if($currentBitSize<$divisorBitSize){

		# Area
		$minSizeArea[$currentBitSize]=0;
		$minSizeAreaCreation[$currentBitSize]=$currentBitSize;
		$creationLevelArea[$currentBitSize]=0;
		$areaTime[$currentBitSize][0]=0;
		$areaTime[$currentBitSize][1]=0;
		$maxAreaTime[$currentBitSize]=0;
		$minSizeAreaWithAdder[$currentBitSize]=0;
		$minSizeAreaCreationWithAdder[$currentBitSize]=$currentBitSize;
		$creationLevelAreaWithAdder[$currentBitSize]=0;
		$areaTimeWithAdder[$currentBitSize]=0;

	}
	else{
		if($currentBitSize<$forcePartition){
			$start=0;
		}
		else{
			$start=1;
		}
		for(my $subBitSize=$start; $subBitSize<=$currentBitSize/2; $subBitSize++){
			if($subBitSize==0){
				$currentCreation=$currentBitSize;
				$entriesBitWidth=bitwidth(((2**$currentBitSize)-1)/$divisor);
				$entryNumber=(2**$currentBitSize);

				# Area
				$currentMinArea=(3*($entryNumber/2-1)+$entryNumber/8)*$entriesBitWidth;
				$minArea=$currentMinArea;
				$areaCreation=$currentCreation;
				$minAreaLevel = 1;
				$minAreaWithAdder=$currentMinArea;
				$areaCreationWithAdder=$currentCreation;
				$minAreaLevelWithAdder = 1;
				$minAdderArea=$areaCreationWithAdder;

				# Time
				if($entryNumber!=0 && $entryNumber!=1){
					$currentTimeMin=( 2 * ( ceil((log($entryNumber)/log(2))) - 1 ) ) + 0.25;
				}
				else{
					$currentTimeMin=0;
				}
				$timeMin=$currentTimeMin;
				$minQTime=$timeMin;
				$minRTime=$timeMin;

				# Combined
				$areaTimeQ=$minQTime;
				$areaTimeR=$minRTime;
				$areaTimeMax=$minQTime;
				$areaTimeMaxWithAdder=$areaTimeMax;

			}
			else{
				$newBitSize=$currentBitSize-$subBitSize;
				$currentCreation=$newBitSize . "+" . $subBitSize;
				
				# START
				
				my $parentLutLeft  = $newBitSize;
				my $parentLutRight = $subBitSize; 
				my $outLut_width   = $parentLutLeft + $parentLutRight;

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
  

				my $comb_q_len  = bitwidth( ((2**$outLut_width)-1) / $divisor );

				my $q_Left_len  = bitwidth( ((2**$parentLutLeft) -1)/$divisor );
				my $q_Right_len = bitwidth( ((2**$parentLutRight)-1)/$divisor );  

				# END

				$entryNumber=($rmLeft_max+1)*($rmRight_max+1);
				$entriesBitWidth=$out_q3_len + $rm_len;
				if($parentLutRight+$q_Left_len > $out_q3_len){
					$adderBitSize=$parentLutRight+$q_Left_len;
				}
				else{
					$adderBitSize=$out_q3_len;
				}

				# Area

				$rLUTSize=(3*($entryNumber/2-1)+$entryNumber/8)*$entriesBitWidth;
				$leftSize=$minSizeArea[$newBitSize];
				$rightSize=$minSizeArea[$subBitSize];
				
				$currentAreaLevel=$creationLevelArea[$newBitSize]>$creationLevelArea[$subBitSize] ? ($creationLevelArea[$newBitSize]+1) : ($creationLevelArea[$subBitSize]+1);
				if($currentAreaLevel>2){
					$CSTsizeArea=( $adderBitSize - $out_q3_len ) * 10.5 + $out_q3_len * 4.5;
				}
				else{
					$CSTsizeArea=0;
				}
				$currentMinAreaLevelWithAdder = $currentAreaLevel;
				if($currentMinAreaLevelWithAdder>2){
					$CSTsizeAdderArea=( $adderBitSize - $out_q3_len ) * 10.5 + $out_q3_len * 4.5;
				}
				else{
					$CSTsizeAdderArea=0;
				}
				$adderSize=$adderBitSize*ceil((log($adderBitSize)/log(2)))*(5/4)+10.5*$adderBitSize;

				$currentMinArea=$rLUTSize+$leftSize+$rightSize+$CSTsizeArea;
				$currentMinAreaWithAdder=$rLUTSize+$leftSize+$rightSize+$CSTsizeAdderArea+$adderSize;
				# End of Area

				# Time of areas best

				$leftAreaQ=$areaTime[$newBitSize][0];
				$rightAreaQ=$areaTime[$subBitSize][0];
				$leftAreaR=$areaTime[$newBitSize][1];
				$rightAreaR=$areaTime[$subBitSize][1];
				
				if($currentAreaLevel>=2 && $entryNumber!=0 && $entryNumber!=1){
					$rLUTTimeArea=( 2 * ( ceil((log($entryNumber)/log(2))) - 1 ) ) + 0.25;
				}
				else{
					$rLUTTimeArea=0;
				}

				if($currentAreaLevel>2){
					$CSTtimeArea=4;
				}
				else{
					$CSTtimeArea=0;
				}
				if($currentMinAreaLevelWithAdder>2){
					$CSTtimeAreaWithAdder=4;
				}
				else{
					$CSTtimeAreaWithAdder=0;
				}

				$currentRminArea=$rightAreaR>$leftAreaR ? $rightAreaR : $leftAreaR;
				$currentRminArea+=$rLUTTimeArea;
				
				$currentQminArea=$rightAreaQ>$leftAreaQ ? $rightAreaQ : $leftAreaQ;
				$currentQminArea=$currentQminArea>$currentRminArea ? $currentQminArea : $currentRminArea;
				$currentQminArea+=$CSTtimeArea;
				$currentQminAreaWithAdder+=$CSTtimeAreaWithAdder;

				$currentMaxTimeArea=$currentQminArea>$currentRminArea ? $currentQminArea : $currentRminArea;
				$adderTime=ceil((log($adderBitSize)/log(2)))*2+4;
				$currentMaxTimeAreaWithAdder=$currentMaxTimeArea+$adderTime;

				# Checks

				# Area
				if($start && $start==$subBitSize){
					$minArea=$currentMinArea;
					$areaCreation=$currentCreation;
					$minAreaLevel=$currentAreaLevel;
					$areaTimeQ=$currentQminArea;
					$areaTimeR=$currentRminArea;
					$areaTimeMax=$currentMaxTimeArea;
					$minAreaWithAdder=$currentMinAreaWithAdder;
					$areaCreationWithAdder=$currentCreation;
					$minAreaLevelWithAdder=$currentMinAreaLevelWithAdder;
					$areaTimeMaxWithAdder=$currentMaxTimeAreaWithAdder;
				}
				else{
					if($minArea>$currentMinArea){
						$minArea=$currentMinArea;
						$areaCreation=$currentCreation;
						$minAreaLevel=$currentAreaLevel;
						$areaTimeQ=$currentQminArea;
						$areaTimeR=$currentRminArea;
						$areaTimeMax=$currentMaxTimeArea;
					}
					elsif ($minArea==$currentMinArea){
						if($areaTimeMax>$currentMaxTimeArea){
							$minArea=$currentMinArea;
							$areaCreation=$currentCreation;
							$minAreaLevel=$currentAreaLevel;
							$areaTimeQ=$currentQminArea;
							$areaTimeR=$currentRminArea;
							$areaTimeMax=$currentMaxTimeArea;
						}
					}

					if($minAreaWithAdder>$currentMinAreaWithAdder){
						$minAreaWithAdder=$currentMinAreaWithAdder;
						$areaCreationWithAdder=$currentCreation;
						$minAreaLevelWithAdder=$currentMinAreaLevelWithAdder;
						$areaTimeMaxWithAdder=$currentMaxTimeAreaWithAdder;
					}
					elsif ($minAreaWithAdder==$currentMinAreaWithAdder){
						if($areaTimeMaxWithAdder>$currentMaxTimeAreaWithAdder){
							$minAreaWithAdder=$currentMinAreaWithAdder;
							$areaCreationWithAdder=$currentCreation;
							$minAreaLevelWithAdder=$currentMinAreaLevelWithAdder;
							$areaTimeMaxWithAdder=$currentMaxTimeAreaWithAdder;
						}
					}
				}

				# End of checks
			}
		}

		# Assigning level bests

		# Area
		$minSizeArea[$currentBitSize]=$minArea;
		$minSizeAreaCreation[$currentBitSize]=$areaCreation;
		$creationLevelArea[$currentBitSize]=$minAreaLevel;
		$areaTime[$currentBitSize][0]=$areaTimeQ;
		$areaTime[$currentBitSize][1]=$areaTimeR;
		$maxAreaTime[$currentBitSize]=$areaTimeMax;
		$minSizeAreaWithAdder[$currentBitSize]=$minAreaWithAdder;
		$minSizeAreaCreationWithAdder[$currentBitSize]=$areaCreationWithAdder;
		$creationLevelAreaWithAdder[$currentBitSize]=$minAreaLevelWithAdder;
		$areaTimeWithAdder[$currentBitSize]=$areaTimeMaxWithAdder;

		# End of assigning level Besta
	}

}

for(my $currentBitSize=1; $currentBitSize<=$bitSize ; $currentBitSize++){ #Find minimum size for all bit sizes till given bit size.

#print "\nCurrnt Bit Size: " . $currentBitSize . "\n\n";
	if($currentBitSize<$divisorBitSize){

		# Time
		$minTime[$currentBitSize][0]=0;
		$minTime[$currentBitSize][1]=0;
		$minTimeCreation[$currentBitSize]=$currentBitSize;
		$creationLevelTime[$currentBitSize]=0;
		$times[$currentBitSize]=0;
		$timeArea[$currentBitSize]=0;
		$minTimeCreationWithAdder[$currentBitSize]=$currentBitSize;
		$creationLevelTimeWithAdder[$currentBitSize]=0;
		$timesWithAdder[$currentBitSize]=0;
		$timeAreaWithAdder[$currentBitSize]=0;

	}
	else{
		$flag=0;
		if($currentBitSize<$forcePartition){
			$start=0;
		}
		else{
			$start=1;
		}
		for(my $subBitSize=$start; $subBitSize<=$currentBitSize/2; $subBitSize++){
			if($subBitSize==0){
				$currentCreation=$currentBitSize;
				$entriesBitWidth=bitwidth(((2**$currentBitSize)-1)/$divisor);
				$entryNumber=(2**$currentBitSize);

				# Time
				if($entryNumber!=0 && $entryNumber!=1){
					$currentTimeMin=( 2 * ( ceil((log($entryNumber)/log(2))) - 1 ) ) + 0.25;
				}
				else{
					$currentTimeMin=0;
				}
				$timeMin=$currentTimeMin;
				$timeCreation=$currentCreation;
				$minTimeLevel = 1;
				$minQTime=$timeMin;
				$minRTime=$timeMin;
				$timeMinAdder=$currentTimeMin;
				$timeCreationAdder=$currentCreation;
				$minTimeLevelAdder = 1;
				$minAdderTime=$timeMinAdder;

				# Combined
				$currentMinArea=(3*($entryNumber/2-1)+$entryNumber/8)*$entriesBitWidth;
				$minArea=$currentMinArea;
				$minAreaTime=$minArea;
				$minAreaTimeWithAdder=$minArea;
#print "CurrentArea: " . $currentMinArea . " PrevArea: " . ((1+$rate)*$minSizeAreaWithAdder[$currentBitSize]) . "\n";
				if($currentMinArea>((1+$rate)*$minSizeAreaWithAdder[$currentBitSize])){
					$timeMinAdder=999999999;
					$minAdderTime=$timeMinAdder;
					$tempTime=$currentTimeMin;
					$tempArea=$minAreaTimeWithAdder;
					$flag=1;
				}
#print "\nPartition: " . $currentCreation . "\n";
#print "currentQmin: " . $minQTime . " currentRmin: " . $minRTime . "\n";
#print "NO ADDER: " . $timeMin . " WITH ADDER: " . $minAdderTime . "\n";

			}
			else{
				$newBitSize=$currentBitSize-$subBitSize;
				$currentCreation=$newBitSize . "+" . $subBitSize;
				
				# START
				
				my $parentLutLeft  = $newBitSize;
				my $parentLutRight = $subBitSize; 
				my $outLut_width   = $parentLutLeft + $parentLutRight;

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
  

				my $comb_q_len  = bitwidth( ((2**$outLut_width)-1) / $divisor );

				my $q_Left_len  = bitwidth( ((2**$parentLutLeft) -1)/$divisor );
				my $q_Right_len = bitwidth( ((2**$parentLutRight)-1)/$divisor );  

				# END

				$entryNumber=($rmLeft_max+1)*($rmRight_max+1);
				$entriesBitWidth=$out_q3_len + $rm_len;
				if($parentLutRight+$q_Left_len > $out_q3_len){
					$adderBitSize=$parentLutRight+$q_Left_len;
				}
				else{
					$adderBitSize=$out_q3_len;
				}

				# Time

				$leftTimeQ=$minTime[$newBitSize][0];
				$rightTimeQ=$minTime[$subBitSize][0];
				$leftTimeR=$minTime[$newBitSize][1];
				$rightTimeR=$minTime[$subBitSize][1];

				$currentTimeLevel=$creationLevelTime[$newBitSize]>$creationLevelTime[$subBitSize] ? ($creationLevelTime[$newBitSize]+1) : ($creationLevelTime[$subBitSize]+1);

				if($currentTimeLevel>2){
					$CSTtimeTime=4;
				}
				else{
					$CSTtimeTime=0;
				}

				if($currentTimeLevel>=2 && $entryNumber!=0 && $entryNumber!=1){
					$rLUTTime=( 2 * ( ceil((log($entryNumber)/log(2))) - 1 ) ) + 0.25;
				}
				else{
					$rLUTTime=0;
				}

				$adderTime=ceil((log($adderBitSize)/log(2)))*2+4;

				$currentRmin=$rightTimeR>$leftTimeR ? $rightTimeR : $leftTimeR;
				$currentRmin+=$rLUTTime;
				
				$currentQmin=$rightTimeQ>$leftTimeQ ? $rightTimeQ : $leftTimeQ;
				$currentQmin=$currentQmin>$currentRmin ? $currentQmin : $currentRmin;
				$currentQmin+=$CSTtimeTime;
				
				$currentMaxTime=$currentQmin>$currentRmin ? $currentQmin : $currentRmin;
				$currentMaxTimeAdder=$currentMaxTime+$adderTime;

				# End of Time
#if( ($currentBitSize==8 && $subBitSize==3) || ($currentBitSize==16 && $subBitSize==$currentBitSize/2) || ($currentBitSize==32 && $subBitSize==$currentBitSize/2) || ($currentBitSize==64 && $subBitSize==$currentBitSize/2) || ($currentBitSize==128 && $subBitSize==$currentBitSize/2)){
#print "CurentBitSize: " . $currentBitSize . " AdderTime: " . $adderTime . " AdderBitSize: " . $adderBitSize . " logOfAdderBitSize: " . (log($adderBitSize)/log(2)) . " CSTTime: " . $CSTtimeTime . " TopModuleQmax: " . ($rightTimeQ>$leftTimeQ ? $rightTimeQ : $leftTimeQ) . " TopModuleRmax: " . ($rightTimeR>$leftTimeR ? $rightTimeR : $leftTimeR) . " rLUTTime: " . $rLUTTime . " rLUTEnteryNum: " . $entryNumber . "\n";
#}

				# Area of times best

				#$currentAreaLevel=$creationLevelArea[$newBitSize]>$creationLevelArea[$subBitSize] ? ($creationLevelArea[$newBitSize]+1) : ($creationLevelArea[$subBitSize]+1);
				#$currentTimeLevel=$creationLevelTime[$newBitSize]>$creationLevelTime[$subBitSize] ? ($creationLevelTime[$newBitSize]+1) : ($creationLevelTime[$subBitSize]+1);
				if($currentTimeLevel>2){
					$CSTsizeArea=( $adderBitSize - $out_q3_len ) * 10.5 + $out_q3_len * 4.5;
				}
				else{
					$CSTsizeArea=0;
				}
				$currentMinAreaLevelWithAdder = $currentTimeLevel;
				if($currentMinAreaLevelWithAdder>2){
					$CSTsizeAdderArea=( $adderBitSize - $out_q3_len ) * 10.5 + $out_q3_len * 4.5;
				}
				else{
					$CSTsizeAdderArea=0;
				}
				$adderSize=$adderBitSize*ceil((log($adderBitSize)/log(2)))*(5/4)+10.5*$adderBitSize;
				$rLUTSize=(3*($entryNumber/2-1)+$entryNumber/8)*$entriesBitWidth;

				$leftSizeTime=$timeArea[$newBitSize];
				$rightSizeTime=$timeArea[$subBitSize];
				
				$currentMinAreaTime=$rLUTSize+$leftSizeTime+$rightSizeTime+$CSTsizeArea;
				$currentMinAreaTimeWithAdder=$rLUTSize+$leftSizeTime+$rightSizeTime+$CSTsizeAdderArea+$adderSize;

				# Checks

				# Time

#print "\nPartition: " . $currentCreation . "\n";
#print "rLUTTime: " . $rLUTTime . " adderTime: " . $adderTime . " currentQmin: " . $currentQmin . " currentRmin: " . $currentRmin . " CSTTime: " . $CSTtimeTime . "\n";
#print "NO ADDER: " . $currentMaxTime . " WITH ADDER: " . $currentMaxTimeAdder . " Time Min: " . $timeMin . "\n";
				if($start && $start==$subBitSize){
					$timeMin=$currentMaxTime;
					$minQTime=$currentQmin;
					$minRTime=$currentRmin;
					$timeCreation=$currentCreation;
					$minTimeLevel=$currentTimeLevel;
					$minAreaTime=$currentMinAreaTime;
					$timeMinAdder=$currentMaxTimeAdder;
					$timeCreationAdder=$currentCreation;
					$minTimeLevelAdder=$currentTimeLevel;
					$minAreaTimeWithAdder=$currentMinAreaTimeWithAdder;
					$flag=0;
				}
				else{
					if($timeMin>$currentMaxTime){
						$timeMin=$currentMaxTime;
						$minQTime=$currentQmin;
						$minRTime=$currentRmin;
						$timeCreation=$currentCreation;
						$minTimeLevel=$currentTimeLevel;
						$minAreaTime=$currentMinAreaTime;
					}
					elsif($timeMin==$currentMaxTime){
						if($minAreaTime>$currentMinAreaTime){
							$timeMin=$currentMaxTime;
							$minQTime=$currentQmin;
							$minRTime=$currentRmin;
							$timeCreation=$currentCreation;
							$minTimeLevel=$currentTimeLevel;
							$minAreaTime=$currentMinAreaTime;
						}
					}
	#print "CurrentArea: " . $currentMinAreaTime . " PrevArea: " . ((1+$rate)*$minSizeAreaWithAdder[$currentBitSize]) . "\n";
					if($timeMinAdder>$currentMaxTimeAdder  && ( ($flag && $currentMinAreaTimeWithAdder<$minAreaTimeWithAdder) || ($currentMinAreaTimeWithAdder<((1+$rate)*$minSizeAreaWithAdder[$currentBitSize]))) ){
						$timeMinAdder=$currentMaxTimeAdder;
						$timeCreationAdder=$currentCreation;
						$minTimeLevelAdder=$currentTimeLevel;
						$minAreaTimeWithAdder=$currentMinAreaTimeWithAdder;
						$flag=0;
					}
					elsif($timeMinAdder==$currentMaxTimeAdder  && ( ($flag && $currentMinAreaTimeWithAdder<$minAreaTimeWithAdder) || ($currentMinAreaTimeWithAdder<((1+$rate)*$minSizeAreaWithAdder[$currentBitSize]))) ){
						if($minAreaTimeWithAdder>=$currentMinAreaTimeWithAdder){
							$timeMinAdder=$currentMaxTimeAdder;
							$timeCreationAdder=$currentCreation;
							$minTimeLevelAdder=$currentTimeLevel;
							$minAreaTimeWithAdder=$currentMinAreaTimeWithAdder;
							$flag=0;
						}
					}
				}

				# End of checks
			}
		}

		# Assigning level bests
		if($timeMinAdder==999999999){
			$timeMinAdder=$tempTime;
			$minTimeLevelAdder=1;
			$timeCreationAdder=$currentBitSize;
			$minAreaTimeWithAdder=$tempArea;
		}
		# Time
		$minTime[$currentBitSize][0]=$minQTime;
		$minTime[$currentBitSize][1]=$minRTime;
		$minTimeCreation[$currentBitSize]=$timeCreation;
		$creationLevelTime[$currentBitSize]=$minTimeLevel;
		$times[$currentBitSize]=$timeMin;
		$timeArea[$currentBitSize]=$minAreaTime;
		$minTimeCreationWithAdder[$currentBitSize]=$timeCreationAdder;
		$creationLevelTimeWithAdder[$currentBitSize]=$minTimeLevelAdder;
		$timesWithAdder[$currentBitSize]=$timeMinAdder;
		$timeAreaWithAdder[$currentBitSize]=$minAreaTimeWithAdder;
#print "\nPartition: " . $timeCreationAdder . "-" . ($timeMinAdder) . "\n";
		
		# End of assigning level Besta
	}

}

if( substr(dec2bin($prints) , -2, 1) ){
	print "\t\t\t\t\t\tSub\t\t\t\t\t\t\t\tFinal\t\t\t\t\n";
	print "\t\t\t\tArea\t\t\tTime\t\t\t\tArea\t\t\t\tTime\t\t\n";
	print "BitLength\tLevel\tPartitioning\tSize\tLevel\tPartitioning\tSize\tLevel\tPartitioning\tSize\tLevel\tPartitioning\tSize\n";
	for(my $i=1; $i<=$bitSize; $i++){
		print $i . "\t" . $creationLevelArea[$i] . "\t" . $minSizeAreaCreation[$i] . "\t" . $minSizeArea[$i] . "\t" . $maxAreaTime[$i] . "\t" . $creationLevelTime[$i] . "\t" . $minTimeCreation[$i] . "\t" . $timeArea[$i] . "\t" . $times[$i] . "\t" . $creationLevelAreaWithAdder[$i] . "\t" . $minSizeAreaCreationWithAdder[$i] . "\t" . $minSizeAreaWithAdder[$i] . "\t" . $areaTimeWithAdder[$i] . "\t" . $creationLevelTimeWithAdder[$i] . "\t" . $minTimeCreationWithAdder[$i] . "\t" . $timeAreaWithAdder[$i] . "\t" . $timesWithAdder[$i] . "\n";
		#print "Bit Length: " . $i . " \tLevel: " . $creationLevelArea[$i] . "\tPartitioning: " . $minSizeAreaCreation[$i] . " \tSize: " . $minSizeArea[$i] . "\n";
	}
}

if( substr(dec2bin($prints) , -1, 1) ){
	# Area Tree
	$finalTreeArea[0][0]=$bitSize;
	$finalTreeArea[0][1]=$creationLevelArea[$bitSize];
	$subCountArea=1;
	for (my $i=0;$i<$subCountArea;$i++){
		if(index($minSizeAreaCreation[$finalTreeArea[$i][0]],"+")!=-1){
			if($i==0){
				$left=substr($minSizeAreaCreationWithAdder[$finalTreeArea[$i][0]], 0, index($minSizeAreaCreationWithAdder[$finalTreeArea[$i][0]], "+"));
				$right=substr($minSizeAreaCreationWithAdder[$finalTreeArea[$i][0]], index($minSizeAreaCreationWithAdder[$finalTreeArea[$i][0]], "+")+1);				
			}
			else{
				$left=substr($minSizeAreaCreation[$finalTreeArea[$i][0]], 0, index($minSizeAreaCreation[$finalTreeArea[$i][0]], "+"));
				$right=substr($minSizeAreaCreation[$finalTreeArea[$i][0]], index($minSizeAreaCreation[$finalTreeArea[$i][0]], "+")+1);
			}
			$finalTreeArea[$subCountArea][0]=$left;
			$finalTreeArea[$subCountArea+1][0]=$right;
			$finalTreeArea[$subCountArea][1]=$creationLevelArea[$left];#$finalTreeArea[$i][1]+1;
			$finalTreeArea[$subCountArea+1][1]=$creationLevelArea[$right];#$finalTreeArea[$i][1]+1;
			$subCountArea+=2;
		}
	}
	# Time Tree
	$finalTreeTime[0][0]=$bitSize;
	$finalTreeTime[0][1]=$creationLevelTime[$bitSize];
	$subCountTime=1;
	for (my $i=0;$i<$subCountTime;$i++){
		if(index($minTimeCreation[$finalTreeTime[$i][0]],"+")!=-1){
			if($i==0){
				$left=substr($minTimeCreationWithAdder[$finalTreeArea[$i][0]], 0, index($minTimeCreationWithAdder[$finalTreeArea[$i][0]], "+"));
				$right=substr($minTimeCreationWithAdder[$finalTreeArea[$i][0]], index($minTimeCreationWithAdder[$finalTreeArea[$i][0]], "+")+1);				
			}
			else{
				$left=substr($minTimeCreation[$finalTreeTime[$i][0]], 0, index($minTimeCreation[$finalTreeTime[$i][0]], "+"));
				$right=substr($minTimeCreation[$finalTreeTime[$i][0]], index($minTimeCreation[$finalTreeTime[$i][0]], "+")+1);
			}
			$finalTreeTime[$subCountTime][0]=$left;
			$finalTreeTime[$subCountTime+1][0]=$right;
			$finalTreeTime[$subCountTime][1]=$creationLevelTime[$left];#$finalTreeTime[$i][1]+1;
			$finalTreeTime[$subCountTime+1][1]=$creationLevelTime[$right];#$finalTreeTime[$i][1]+1;
			$subCountTime+=2;
		}
	}
	# LUTs Area
	$iLUTnumArea=0;
	$rLUTnumArea=0;
	print "\nArea Tree\n";
	for (my $j=0; $j<=$creationLevelArea[$bitSize]; $j++){
		print "Level$j: ";
		for (my $i=0;$i<$subCountArea;$i++){
			$found=0;
			if($j==$finalTreeArea[$i][1]){
				print $finalTreeArea[$i][0] . " ";
				if($j==0 || $j==1){
					for (my $k=0;$k<$iLUTnumArea;$k++){
						if ($iLUTsArea[$k]==$finalTreeArea[$i][0]){
							$found=1;
						}
					}
					if($found==0){
						$iLUTsArea[$iLUTnumArea]=$finalTreeArea[$i][0];
						$iLUTsAreaLevel[$iLUTnumArea]=$j;
						$iLUTnumArea+=1;
					}
				}
				elsif($j==$creationLevelArea[$bitSize]){
					$topLevelArea=$finalTreeArea[$i][0];
					$topLevelAreaLevel=$j;
				}
				else{
					for (my $k=0;$k<$rLUTnumArea;$k++){
						if ($rLUTsArea[$k]==$finalTreeArea[$i][0]){
							$found=1;
						}
					}
					if($found==0){
						$rLUTsArea[$rLUTnumArea]=$finalTreeArea[$i][0];
						$rLUTsAreaLevel[$rLUTnumArea]=$j;
						$rLUTnumArea+=1;
					}
				}
			}
		}
		print "\n";
	}
	# LUTs Time
	$iLUTnumTime=0;
	$rLUTnumTime=0;
	print "\nTime Tree\n";
	for (my $j=0; $j<=$creationLevelTime[$bitSize]; $j++){
		print "Level$j: ";
		for (my $i=0;$i<$subCountTime;$i++){
			$found=0;
			if($j==$finalTreeTime[$i][1]){
				print $finalTreeTime[$i][0] . " ";
				if($j==0 || $j==1){
					for (my $k=0;$k<$iLUTnumTime;$k++){
						if ($iLUTsTime[$k]==$finalTreeTime[$i][0]){
							$found=1;
						}
					}
					if($found==0){
						$iLUTsTime[$iLUTnumTime]=$finalTreeTime[$i][0];
						$iLUTsTimeLevel[$iLUTnumTime]=$j;
						$iLUTnumTime+=1;
					}
				}
				elsif($j==$creationLevelTime[$bitSize]){
					$topLevelTime=$finalTreeTime[$i][0];
					$topLevelTimeLevel=$j;
				}
				else{
					for (my $k=0;$k<$rLUTnumTime;$k++){
						if ($rLUTsTime[$k]==$finalTreeTime[$i][0]){
							$found=1;
						}
					}
					if($found==0){
						$rLUTsTime[$rLUTnumTime]=$finalTreeTime[$i][0];
						$rLUTsTimeLevel[$rLUTnumTime]=$j;
						$rLUTnumTime+=1;
					}
				}
			}
		}
		print "\n";
	}
	# Area LUTs to Create
	print "## AREA ##\niLUTs\n";
	for (my $i=0;$i<$iLUTnumArea;$i++){
		if($i==$iLUTnumArea-1){
			print $iLUTsArea[$i] . "\n";
		}
		else{
			print $iLUTsArea[$i] . " - ";
		}
	}
	print "rLUTs\n";
	for (my $i=0;$i<$rLUTnumArea;$i++){
		if($i==$rLUTnumArea-1){
			print $rLUTsArea[$i] . "\n";
		}
		else{
			print $rLUTsArea[$i] . " - ";
		}
	}
	print "TopLevel\n" . $topLevelArea . "\n";
	# Time LUTs to Create
	print "## Time ##\niLUTs\n";
	for (my $i=0;$i<$iLUTnumTime;$i++){
		if($i==$iLUTnumTime-1){
			print $iLUTsTime[$i] . "\n";
		}
		else{
			print $iLUTsTime[$i] . " - ";
		}
	}
	print "rLUTs\n";
	for (my $i=0;$i<$rLUTnumTime;$i++){
		if($i==$rLUTnumTime-1){
			print $rLUTsTime[$i] . "\n";
		}
		else{
			print $rLUTsTime[$i] . " - ";
		}
	}
	print "TopLevel\n" . $topLevelTime . "\n";
}

print "\n";

open (areaFile, ">areaPartitioning");

# Create Verilog for area
for (my $i=0;$i<$iLUTnumArea;$i++){
	print areaFile $iLUTsAreaLevel[$i] . "-" . $iLUTsArea[$i] . ":" . $minSizeAreaCreation[$iLUTsArea[$i]] . "\n";
#	initLutGen($divisor,$iLUTsArea[$i],$file_name);
}
for (my $i=0;$i<$rLUTnumArea;$i++){
	print areaFile $rLUTsAreaLevel[$i] . "-" . $rLUTsArea[$i] . ":" . $minSizeAreaCreation[$rLUTsArea[$i]] . "\n";
#	$left=substr($minSizeAreaCreation[$rLUTsArea[$i]], 0, index($minSizeAreaCreation[$rLUTsArea[$i]], "+"));
#	$right=substr($minSizeAreaCreation[$rLUTsArea[$i]], index($minSizeAreaCreation[$rLUTsArea[$i]], "+")+1);
#	transLutGen($divisor, $left, $right,$file_name);
}
if($topLevelArea!=0){
	print areaFile $topLevelAreaLevel . "-" . $topLevelArea . ":" . $minSizeAreaCreation[$topLevelArea] . "\n";
#	$left=substr($minSizeAreaCreation[$topLevelArea], 0, index($minSizeAreaCreation[$topLevelArea], "+"));
#	$right=substr($minSizeAreaCreation[$topLevelArea], index($minSizeAreaCreation[$topLevelArea], "+")+1);
#	transLutGen($divisor, $left, $right,$file_name);
}

close(areaFile);

open (timeFile, ">timePartitioning");

# Create Verilog for time
for (my $i=0;$i<$iLUTnumTime;$i++){
	print timeFile $iLUTsTimeLevel[$i] . "-" . $iLUTsTime[$i] . ":" . $minTimeCreation[$iLUTsTime[$i]] . "\n";
#	initLutGen($divisor,$iLUTsTime[$i],$file_name);
}
for (my $i=0;$i<$rLUTnumTime;$i++){
	print timeFile $rLUTsTimeLevel[$i] . "-" . $rLUTsTime[$i] . ":" . $minTimeCreation[$rLUTsTime[$i]] . "\n";
#	$left=substr($minTimeCreation[$rLUTsTime[$i]], 0, index($minTimeCreation[$rLUTsTime[$i]], "+"));
#	$right=substr($minTimeCreation[$rLUTsTime[$i]], index($minTimeCreation[$rLUTsTime[$i]], "+")+1);
#	transLutGen($divisor, $left, $right,$file_name);
}
if($topLevelTime!=0){
	print timeFile $topLevelTimeLevel . "-" . $topLevelTime . ":" . $minTimeCreation[$topLevelTime] . "\n";
#	$left=substr($minTimeCreation[$topLevelTime], 0, index($minTimeCreation[$topLevelTime], "+"));
#	$right=substr($minTimeCreation[$topLevelTime], index($minTimeCreation[$topLevelTime], "+")+1);
#	transLutGen($divisor, $left, $right,$file_name);
}

close(timeFile);



