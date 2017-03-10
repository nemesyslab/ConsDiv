#############################################################################################
##                                                                                         ##
##                 EFFICIENT COMBINATIONAL CIRCUITS FOR CONSTANT DIVISION                  ##
##	                      ------- SYNTHESIZER ----------                               ##
##                                                                                         ##
#############################################################################################
##                                                                                         ##
##                                                                                         ##
##   Name          : synthesize.pl                                                         ##
##   Creation Date : 21.06.2013                                                            ##
##   Description   : Coordinates the synthesis operation                                   ##
##                                                                                         ##
##                                                                                         ##
##                                                                                         ##
##  Initial Placement :                                                        21.06.2013  ##
##                                                                            ANIL BAYRAM  ##
##                                                                                         ##                                                                    
#############################################################################################
## Sample call: ">> perl synthesize.pl                                                      #
#############################################################################################

#!C:/strawberry/perl/bin

use POSIX;
use POSIX qw/floor/;
use warnings;
use strict;
use Cwd;
use Scalar::Util qw(looks_like_number);
use File::Copy;
use File::Path;


#****************************************************************************************
# -- SUBMODULE: replace_content("string to be replaced","new string","file location")
#********************************************
# -- Converts the decimal into its BINARY Representation.
#****************************************************************************************                                                                                     
sub replace_content{

  open(FILE, "<$_[2]") || die "File not found";
	my @lines = <FILE>;
	close(FILE);

  
	my @newlines;
	foreach(@lines) {
	   $_ =~ s/$_[0]/$_[1]/g;
	   push(@newlines,$_);
	}

	open(FILE, ">$_[2]") || die "File not found";
	print FILE @newlines;
	close(FILE);
  
}
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *




# Get the Current Working Directory:
# The working directory is supposed as the syn/sandbox
my $dir = cwd();


my $curr_divisor;
my $curr_bit_len;
my $wrapper_path;

unlink <./../sandbox/*>; ## to assure only to unlink sandbox folder
chdir ("./../sandbox/");

## Refresh the result Folders, Create if there is none.
#unlink <../results/*>; unlink <../results/dinechin/*/*>; unlink <../results/divConq/*/*>;
#rmtree('../results/dinechin/'); rmtree('../results/divConq/');
if (!(-d "../results/dinechin")) {
   mkdir("../results/dinechin");
}
if (!(-d "../results/divConq")) {
   mkdir("../results/divConq");
}
 
#########################################################################################
## Synthesize for the DIVIDE AND CONQUER method 
######################################################################################### 

my @files = <../../gen/verilog/divConq/divBy*.v> ;
my $startTime = join('_', split(/ /, localtime(time)));

for my $file (@files) {

  $file =~ s/.*\///;
  
  if( $file =~ /divBy_([0-9]+)N([0-9]+)\.v/ ){
    $curr_divisor = $1; $curr_bit_len = $2;
  }else{
    die ("ERROR: Cannot get Divisor and Bit_Length information from $file\n\n");
  }

  unlink <work/*>;## removes contents
  mkdir("work"); ## If there isnt one already.

  # Copy and rename the topmodule of Design Under Synthesis
  copy("$dir/../../gen/verilog/divConq/$file" , "./divByN.v") || die ("WTF\n");
  
  my $ttf = join('',("divBy_",$curr_divisor,"N",$curr_bit_len) );
  replace_content($ttf,"divByN","./divByN.v");

  # Copy the related wrapper.
  $wrapper_path = join('',"../wrapper/wrapper_",$curr_divisor,"N",$curr_bit_len,".v");
  copy("$wrapper_path" , "./wrapper.v") || die ("WTF2\n");

  system("dc_shell-t -f ../common/synultra.tcl > .log");
  
  mkdir("./../results/divConq/${curr_divisor}N${curr_bit_len}_${startTime}"); 
  
  for my $fileToMove ("", "compile", "timing", "area", "check", "bestsTiming", "bestsArea", "bestsSummary") {
	    copy("$fileToMove.log", "./../results/divConq/${curr_divisor}N${curr_bit_len}_${startTime}/${fileToMove}_${curr_divisor}N${curr_bit_len}.log");
	}
	copy("bestsdivByN.vg", "./../results/divConq/${curr_divisor}N${curr_bit_len}_${startTime}/bestsdivBy${curr_divisor}N${curr_bit_len}.vg");
  
  system("perl -ne \"/error/i && print\" > ./../results/divConq/${curr_divisor}N${curr_bit_len}_${startTime}/ERRATA .log compile.log timing.log area.log check.log");
    
  open (MYFILE, ">> ./../results/divConq_results_${startTime}.txt");
  print MYFILE "${curr_divisor}N${curr_bit_len}_${startTime} :        ";
  close(MYFILE);
  system("perl -ne \"/bestC/i && print\" >> ./../results/divConq_results_${startTime}.txt bestsSummary.log");
  
  
}

unlink <./../sandbox/*>; ## to assure only to unlink sandbox folder
 
 
#########################################################################################
 
 
 
 
