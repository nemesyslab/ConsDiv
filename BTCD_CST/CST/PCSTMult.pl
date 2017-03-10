#use diagnostics; 
#use strict;
use Class::Struct;
use POSIX qw(ceil floor);
struct Bit => 
{         
    name => '$',
	delay => '$',
	in	=> '$', 
};
struct Delay =>
{
	celltype => '$',#can be halfadder or full adder (FA:1,HA:0)
	outtype => '$',#can be sum delay or cout delay (Sum:1,Cout:0)
	bitno => '$',#bit number(in0:0,in1:1,in2:2)
	delay => '$',#delay amount
};
struct FA => 
{         
    in   => '@',#3 elements in0,in1,in2
    sum  => '$',
    cout => '$',
	maxsumdelay => '$',
	maxcoutdelay => '$',
	celltype => '$',#Cell type 1
};
struct HA => 
{         
    in   => '@',#2 elements in0,in1
    sum  => '$',
    cout => '$',
	maxsumdelay => '$',
	maxcoutdelay => '$',
	celltype => '$',#Cell type 0
};

######--Reads Cell Delays From CellDelays.log File--######
open (CellDelays, "< CellDelays.log") or die "Couldn't open CELLDELAYS.LOG \n$!\n";
	my @cell_delay = <CellDelays>;
	for($i=0;$i<=$#cell_delay;$i++)
	{
		chop($cell_delay[$i]);
		$cell_delay[$i] =~ s/^\s+//; #remove leading spaces
		$cell_delay[$i] =~ s/\s+$//; #remove trailing spaces
		if($cell_delay[$i] =~ /FASumDelay: *(.*)/)
		{
			@FASumDelay = split(/ +/,$1);
		}
		if($cell_delay[$i] =~ /HASumDelay: *(.*)/)
		{
			@HASumDelay = split(/ +/,$1);
		}
		if($cell_delay[$i] =~ /FACoutDelay: *(.*)/)
		{
			@FACoutDelay = split(/ +/,$1);
		}
		if($cell_delay[$i] =~ /HACoutDelay: *(.*)/)
		{
			@HACoutDelay = split(/ +/,$1);
		}
	}
close(CellDelays);
###########################################################

# @FASumDelay = (1.910,1.910,0.710);
# @FACoutDelay = (1.065,1.065,1.065);
# @HASumDelay = (1.01,1.01);
# @HACoutDelay = (0.625,0.625);

########--Sorts Delays and Creates a Delay Array--#########
for ($i=0;$i<3;$i++){
	if ($FASumDelay[$i] >= $FACoutDelay[$i])
	{
		$delayarray[$i] = Delay -> new(celltype => 1,outtype => 1,bitno => $i,delay => $FASumDelay[$i]);
	}
	else
	{
		$delayarray[$i] = Delay -> new(celltype => 1,outtype => 0,bitno => $i,delay => $FACoutDelay[$i]);
	}
}
for ($i=0;$i<2;$i++){
	if ($HASumDelay[$i] >= $HACoutDelay[$i])
	{
		$delayarray[$i+3] = Delay -> new(celltype => 0,outtype =>1 ,bitno => $i,delay => $HASumDelay[$i]);
	}
	else
	{
		$delayarray[$i+3] = Delay -> new(celltype => 0,outtype =>0 ,bitno => $i,delay => $HACoutDelay[$i]);
	}
}
for ($i=0;$i<5;$i++)
{
	print $delayarray[$i]->delay," ";
}
print "\n";
for ($i=4;$i>=0;$i--)
{
	for($j=1;$j<=$i;$j++)
	{
		if($delayarray[$j-1]->delay < $delayarray[$j]->delay)
		{
			$temp1 = $delayarray[$j-1];
			$delayarray[$j-1] = $delayarray[$j];
			$delayarray[$j] = $temp1;
		}
	}
}
# for ($i=0;$i<5;$i++)
# {
	# print $delayarray[$i]->bitno," ";
# }
# print "\n";



###########################################################

##########---Finds Max Bit Value and Its Index---##########
sub findmax{
	my (@array) = @_;
	my ($i,$index);
	my ($max) = 0;
	for($i=0;$i<=$#array;$i++)
	{	
		if ($array[$i] > $max)
		{
			$max = $array[$i];
			$index = $i;
		}
	}
	return ($max,$index);
}
###########################################################


######################---Main---###########################
$input_mode = 0;
$temp_arg = "";
$random_switch = 0;
$seed = 0;
##################---Parsing Argument---###################
### Check for some arguments
if (!defined($ARGV[0])) 
{
  die "1) KbxLb Multiplies K and L bit numbers 
	   2) KxLb Adds K(constant) L bit numbers
	   3) \"1 2 3 4 5 2 1\" The part in the quotation mark is the first line of addition \n";
}
elsif ($ARGV[0] eq "-h" || $ARGV[0] eq "--help" )
{
  die "1) KbxLb Multiplies K and L bit numbers 
	   2) KxLb Adds K(constant) L bit numbers
	   3) \"1 2 3 4 5 2 1\" The part in the quotation mark is the first line of addition \n";
}

###---Deciding input mode KbxLb or KxLb or "x y z..."---###
if ($ARGV[0] =~ /[0-9]+bx[0-9]+b/) 
{
	$input_mode = 1;
}
elsif ($ARGV[0] =~ /[0-9]+x[0-9]+b/)
{
	$input_mode = 2;
}
else
{
	$input_mode = 3;
}
print "--input_mode--",$input_mode,"\n";
###########################################################

###############---Parsing the first input---###############
if ($input_mode == 1)
{
	$index_of_x = index($ARGV[0],'x');
	$s1 = substr $ARGV[0], 0, $index_of_x;
	$s2 = substr $ARGV[0], $index_of_x+1;
	$b1 = index($s1,'b');
	$b2 = index($s2,'b');

	if (int (substr $s1,0,$b1) < int (substr $s2,0,$b2))
	{
		$num1 = int (substr $s1,0,$b1);
		$num2 = int (substr $s2,0,$b2);
	}
	else
	{
		$num2 = int (substr $s1,0,$b1);
		$num1 = int (substr $s2,0,$b2);
	}

	if ($num1<1||$num2<1)
	{
		die "Wrong format !!!\n";
	}

	print $num1," ",$num2,"\n";
	$temp = $num1;
	$size = $num1+$num2-1;
	$length = $num1+$num2;
	for ($i=0;$i<$size;$i++)
	{
		if($i < $num1)
		{
			$firstline[$i] = $i+1;
		}
		elsif($i < $num2)
		{
			$firstline[$i] = $num1;
		}
		else
		{
			$temp = $temp - 1;
			$firstline[$i] = $temp;
		}
			
	}

	for ($i=0;$i<$size;$i++)
	{
		print $firstline[$i]," ";
	}
		
	@firstline = reverse (@firstline);
}
elsif ($input_mode == 2)
{
	$index_of_x = index($ARGV[0],'x');
	$s1 = substr $ARGV[0], 0, $index_of_x;
	$s2 = substr $ARGV[0], $index_of_x+1;
	$b2 = index($s2,'b');

	$num1 = int ($s1);
	$num2 = int (substr $s2,0,$b2);

	if ($num1<1||$num2<1)
	{
		die "Wrong format !!!\n";
	}
	
	print "Const: ",$num1," ","Num2: ",$num2,"\n";
	$size = $num2;
	$length = ceil(log($num1)/log(2)) + $num2;
	print "Size: ",$size," ","Length: ",$length,"\n";
	
	for ($i=0;$i<$size;$i++)
	{
		$firstline[$i] = $num1;
	}
}
elsif ($input_mode == 3)
{
	$temp_arg = $ARGV[0];
	$temp_arg =~ s/^\s+//; #remove leading spaces
	$temp_arg =~ s/\s+$//; #remove trailing spaces
	@firstline = split(/ +/,$temp_arg);
	@firstline = reverse(@firstline);
	$size = scalar(@firstline);
	for ($i=0;$i<$size;$i++)
	{
		$length += ($firstline[$i]*(2**$i));
	}	
	$length = ceil(log($length)/log(2));
	print "Size: ",$size," ","Length: ",$length,"\n";
}
###########################################################

##############---Parsing possible switches---##############
#(Time routed, Random Routed)
if ($#ARGV == 0)
{
	$random_switch = 0;
}
elsif ($#ARGV == 2)
{
	if ($ARGV[1] eq "-r" || $ARGV[1] eq "-R")
	{
		$seed = $ARGV[2];
		print "Seed: ",$seed,"\n";
		srand ($seed);
		$random_switch = 1;
	}
	else 
	{
		die "Enter a valid switch !!!\n";
	}
}
else 
{
	die "Wrong format !!!\n";
}
###########################################################
	
($max,$index) = &findmax(@firstline);
$rownum = $max;

for ($i=$size;$i<$length;$i++)
{
	$firstline[$i] = 0;
}
for($i=0;$i<$length;$i++)
{
	$cell[$i] = 0;
	$plowingflag[$i] = 0;
}
@temparray = @firstline;
# for ($i=$#firstline;$i>=0;$i--)
# {
	# print $firstline[$i]," ";
# }
# print "\n";
for ($i=0;$i<=$#firstline;$i++)
{
	$cstlevels[0][$i]=$firstline[$i];
}
###########################################################

###############---Creating Guidance Array---###############
# for ($i=0;$max>2;$i++)
# {	
	# $max = ($max - int($max/3));
	# $guidance[$i] = $max;
# }
# print "Guidance: ";
# for ($i=0;$i<=$#guidance;$i++)
# {
	# print $guidance[$i]," ";
# }
print "\n","CST :";

for ($i=$#temparray;$i>=0;$i--)
{
	print$temparray[$i]," ";
} 
print "\n"; 
###########################################################

####################---Calculations---#####################

#($max,$index) = &findmax(@temparray);
$j=0;
while (1)
{
	($max,$index) = &findmax(@temparray);
	if ($max <= 2)
	{
		last;
	}

	$guidance[$j] = ($max - int($max/3));
#print $index," ",$max,"\n";
#################---Plowing Decision---####################
	for ($i=0;$i<$index;$i++)
	{
		if ($temparray[$i]>2)
		{
			last;
		}
		elsif ($temparray[$i]==2)
		{	
			$plowingflag[$i] = 1;
		}
	}
###########################################################

#####################---Finding FAs---#####################
	for ($i=0;$i<=$#temparray;$i++)
	{	
		$cell[$i] += int($temparray[$i]/3);
		$temparray[$i] -= (int($temparray[$i]/3)*2);			
	}
	for ($i=0;$i<$#temparray;$i++)
	{
		$temparray[$i+1] += $cell[$i];
	}
###########################################################

####---Checking Guidance and Adding HAs If Necessary---####
	for ($i=0;$i<=$#temparray;$i++)
	{
		if ($temparray[$i] > $guidance [$j])
		{
			$cell[$i] += 0.5;
			$temparray [$i] -=1;
			$temparray [$i+1] +=1;
		}
	}
###########################################################

######################---Plowing---########################
	for ($i=0;$i<$#plowingflag;$i++)
	{
		if ($plowingflag[$i] == 1)
		{
			$cell[$i] += 0.5;
			$temparray[$i] -= 1;
			$temparray[$i+1] += 1;
		}

	}
############################################################
	for ($i=0;$i<=$#temparray;$i++)
	{
		$cstlevels[$j+1][$i] = $temparray[$i];
		$celllevels[$j][$i] = $cell[$i];
	}

	print "Cell:";
	for ($i=$#cell;$i>=0;$i--)
	{
		print$cell[$i]," ";
	} 
	print "\n","CST :";
	for ($i=$#temparray;$i>=0;$i--)
	{
		print$temparray[$i]," ";
	} 
	print "\n";
	for($i=0;$i<=$#plowingflag;$i++)
	{
		$plowingflag[$i] = 0;
		$cell[$i] = 0;
	}
	$j++;
}
for ($i=0;$i<=$#temparray;$i++)
{
	$celllevels[$#guidance+1][$i] = 0;
}
###########################################################

for ($i=0;$i<=($#guidance+1);$i++)
{
	for ($j=0;$j<$rownum;$j++)
	{
		for ($k=0;$k<$length;$k++)
		{
			$bitarray [$i][$j][$k] = 0;
		}
	
	}
}

for ($i=0;$i<=($#guidance+1);$i++)
{
	for ($j=0;$j<$rownum;$j++)
	{
		for ($k=0;$k<$length;$k++)
		{
			$cellarray [$i][$j][$k] = 0;
		}
	
	}
}

if($input_mode == 1)
{
	for ($j=0;$j<$length;$j++)
	{
		for ($k=0;$k<$cstlevels[0][$j];$k++)
		{
			$bitarray [0][$k][$j] = Bit -> new(name => "Bit_"."0"."_".$k."_".$j,delay => 0.625,in => 0);
		}
	}
}
else 
{
	for ($j=0;$j<$length;$j++)
	{
		for ($k=0;$k<$cstlevels[0][$j];$k++)
		{
			$bitarray [0][$k][$j] = Bit -> new(name => "Bit_"."0"."_".$k."_".$j,delay => 0,in => 0);
		}
	}
}

for ($j=0;$j<$length;$j++)
{
	for ($k=0;$k<$cstlevels[0][$j];$k++)
	{
		print $bitarray [0][$k][$j] -> name," ";
	}
	print "\n";
}

for($i=0;$i<=($#guidance+1);$i++)
{
	for ($j=0;$j<$length;$j++)
	{
		if (int($celllevels[$i][$j]) != $celllevels[$i][$j])
		{
			$FAs = int($celllevels[$i][$j]);
			$FA_HA_Couts = (int($celllevels[$i][$j+1]+0.5)+int($celllevels[$i][$j]));
			$cellarray [$i][int($celllevels[$i][$j])][$j] = HA-> new(in => [" "," "],sum => "Bit_".($i+1)."_".$FAs."_".$j,cout => "Bit_".($i+1)."_".$FA_HA_Couts."_".($j+1),maxsumdelay => 0,maxcoutdelay => 0,celltype => 0);
		}
		for ($k=0;$k<int($celllevels[$i][$j]);$k++)
		{
			$FA_HA_Sums = int($celllevels[$i][$j+1]+0.5);
			$cellarray [$i][$k][$j] = FA-> new(in => [" "," "," "],sum => "Bit_".($i+1)."_".$k."_".$j,cout => "Bit_".($i+1)."_".($FA_HA_Sums+$k)."_".($j+1),maxsumdelay => 0,maxcoutdelay => 0,celltype => 1);
		}
		
	}
}

for ($j=0;$j<$length;$j++)
{
	print $celllevels[$#guidance+1][$j]," ";
}
print "\n";

print $bitarray[0][0][0] -> name,"*","\n";

# require "Townsend_Timing.pl" or die("Couldn't find file Townsend_Timing.pl!!!");
require "TimingMult.pl" or die ("Couldn't find file Timing.pl!!!");
require "TestMult.pl" or die ("Couldn't find file Test.pl!!!");
