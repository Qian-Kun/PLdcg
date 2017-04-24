#! /usr/bin/perl -w
use strict;
use warnings;

if(@ARGV!=3)
{
	print "\nperl $0 <Pfam_domain.tab> <Pfam out by HMMER> <output file>\n";
	exit;
}

# hmmsearch --domtblout <Pfam_domain.tab> <hmmfile> <seqdb>

# target name        accession   tlen query name           accession   qlen   E-value  score  bias   #  of  c-Evalue  i-Evalue  score  bias  from    to  from    to  from    to  acc description of target
# ENH70985.1           -           1231 AAA                  PF00004.24   132   1.1e-08   27.9   0.7   2   2   9.1e-06   1.5e-05   17.8   0.0     2   118  1041  1191  1040  1196 0.68 -

my %pfamanno;
open HMM,"$ARGV[1]" || die "Cannot open the file '$ARGV[1]'.\n";
$/="Query\:";<HMM>;$/="\n";
while(<HMM>)
{
	my $query=$_;
	chomp $query;
	$query=(split(/\s+/,$query))[1];
	my $accession=<HMM>;
	chomp $accession;
	$accession=(split(/\s+/,$accession))[1];
	my $description=<HMM>;
	chomp $description;
	$description=~s/^Description: //;
	$pfamanno{$accession}=$description;
	<HMM>;#Scores for complete sequences (score includes all domains):
	<HMM>;#   --- full sequence ---   --- best 1 domain ---    -#dom-
	<HMM>;#    E-value  score  bias    E-value  score  bias    exp  N  Sequence Description
	<HMM>;#    ------- ------ -----    ------- ------ -----   ---- --  -------- -----------
	my $map=<HMM>;
	chomp $map;
	if($map ne "")
	{
		my @sp=split(/\s+/,$map);
		while($map ne "" && (scalar @sp)>=10)#    1.7e-09   36.8   0.0    3.1e-09   36.0   0.0    1.5  1  AG1IA002820 
		{
#			print OUT "$sp[9]\t$query\t$accession\t$sp[1]\t$sp[2]\t$sp[3]\t$sp[4]\t$sp[5]\t$sp[6]\t--\t$description\n";
			$map=<HMM>;
			chomp $map;
			@sp=split(/\s+/,$map);
		}
	}
	$/="Query\:";
	<HMM>;
	$/="\n";
}
$/="\n";
close HMM;

open OUT,">$ARGV[2]";
print OUT "Gene\tPfamQuery\tPfamAccession\tFullE-value\tFullScore\tFullBias\tDomainE-value\tDomainScore\tDomainBias\tGeneDescription\tPfamDescription\n";
open F,"$ARGV[0]" || die "Cannot open the file '$ARGV[0]'.\n";
while(<F>)
{
	chomp;
	my @sp=split(/\s+/,$_);
	if($_ ne "" && !($_=~/^\#/) && $sp[12]<=0.01)
	{
		print OUT "$sp[0]\t$sp[3]\t$sp[4]\t$sp[6]\t$sp[7]\t$sp[8]\t$sp[12]\t$sp[13]\t$sp[14]\t --\t$pfamanno{$sp[4]}\n";
	}
}
close F;
close OUT;


__END__
