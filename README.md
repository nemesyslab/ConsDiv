#To generate BTCD and BTCD_CST:  

<b>perl gen.pl</b> divisor dividend_bitlength k_value

<b>perl RTLgenerator.pl</b>  divisor areaPartitioning
    
    
#To generate BTCD with area or time driven methods:

For print selection enter number between 0-3, first bit 1 for tree, second bit 1 for print calculations

PartitionType can be areaPartitioning or timePartitioning
<br><br>

<b>perl estimator.pl</b> dividend_bitlength divisor rate force_partition prints_selection

<b>perl RTLgenerator.pl</b> divisor PartitionType
 
 
#To generate BTCD_CST with area or time driven methods:

For print selection enter number between 0-3, first bit 1 for tree, second bit 1 for print calculations

PartitionType can be areaPartitioning or timePartitioning

<br><br>
<b>perl estimator_CST.pl</b> dividend_bitlength divisor rate force_partition prints_selection

<b>perl RTLgenerator.pl</b> divisor PartitionType
 
 
#To generate LinArch:
 
<b>perl generate.pl</b> divisor dividend_bitlength k_value
 
 
#To generate Reciprocal:
 
<b>perl recip.pl</b> dividend_bitlength divisor

#To generate TestBench and Wrapper:
 
<b>perl tb_gen.pl</b> divisor dividend_bitlength

<b>perl wrapper_gen.pl</b> divisor dividend_bitlength

<br><br>
Synthesize files under Synthesize.
