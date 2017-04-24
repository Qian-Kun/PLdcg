#! /usr/bin/perl -w
use strict;
use warnings;

if(@ARGV!=2)
{
	print "\nperl $0 <out.step2> <output>\n";
	exit;
}

my (%query,%accession,%fullscore,%fullevalue,%fullbias,%domainevalue,%domainscore,%domainbias,%geneanno,%pfamanno,%genedomain)=();
my 	$line=0;
if($ARGV[0]=~/\.gz$/)
{
	open IN,"gzip -dc $ARGV[0] | " || die "Cannot open the file '$ARGV[0]'.\n";
}
else
{
	open IN,"$ARGV[0]" || die "Cannot open the file '$ARGV[0]'.\n";
}
while(<IN>)
{
	chomp;
	my @sp=split(/\t+/,$_);
	$line++;
	if($line>1)
	{
		$query{$sp[0]}.="$sp[1]\;";
		$accession{$sp[0]}.="$sp[2]\;";
		$fullevalue{$sp[0]}.="$sp[3]\;";
		$fullscore{$sp[0]}.="$sp[4]\;";
		$fullbias{$sp[0]}.="$sp[5]\;";
		$domainevalue{$sp[0]}.="$sp[6]\;";
		$domainscore{$sp[0]}.="$sp[7]\;";
		$domainbias{$sp[0]}.="$sp[8]\;";
		$geneanno{$sp[0]}="$sp[9]";
		$pfamanno{$sp[0]}.="$sp[10]\;";
		$genedomain{$sp[0]}.="$sp[0]\t$sp[2]\t$sp[1]\t$sp[3]\t$sp[6]\t$sp[10]\n";
	}
}
close IN;

open GD,">$ARGV[1]";
foreach my $genename(sort keys %query)
{
	$query{$genename}=~s/\;$//;
	$accession{$genename}=~s/\;$//;
	$fullevalue{$genename}=~s/\;$//;
	$fullscore{$genename}=~s/\;$//;
	$fullbias{$genename}=~s/\;$//;
	$domainevalue{$genename}=~s/\;$//;
	$domainscore{$genename}=~s/\;$//;
	$domainbias{$genename}=~s/\;$//;
	$pfamanno{$genename}=~s/\;$//;
	print GD $genedomain{$genename};
}
close GD;


__END__
