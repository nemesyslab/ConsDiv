#To generate BTCD and BTCD_CST:  

<b>perl gen.pl</b> divisor dividend_bitlength k_value

perl RTLgenerator.pl  divisor areaPartitioning
    
    
#To generate BTCD with area or time driven methods:

For print selection enter number between 0-3, first bit 1 for tree, second bit 1 for print calculations

PartitionType can be areaPartitioning or timePartitioning
<br><br>

perl estimator.pl dividend_bitlength divisor rate force_partition prints_selection

perl RTLgenerator.pl divisor PartitionType
 
 
#To generate BTCD_CST with area or time driven methods:

For print selection enter number between 0-3, first bit 1 for tree, second bit 1 for print calculations

PartitionType can be areaPartitioning or timePartitioning

<br><br>
perl estimator_CST.pl dividend_bitlength divisor rate force_partition prints_selection

perl RTLgenerator.pl divisor PartitionType
 
 
#To generate LinArch:
 
perl generate.pl divisor dividend_bitlength k_value
 
 
#To generate Reciprocal:
 
perl recip.pl dividend_bitlength divisor

#To generate TestBench and Wrapper:
 
perl tb_gen.pl divisor dividend_bitlength

perl wrapper_gen.pl divisor dividend_bitlength

<br><br>
Synthesize files under Synthesize.
