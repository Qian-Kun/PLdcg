#! /usr/bin/perl -w
use strict;
use warnings;

if(@ARGV!=2)
{
	print "\nperl $0 <out.step1> <output>\n";
	exit;
}

open OUT,">$ARGV[1]";
if($ARGV[0]=~/\.gz$/)
{
	open F,"gzip -dc $ARGV[0]| " || die "Cannot open the file '$ARGV[0]'.\n";
}
else
{
	open F,"$ARGV[0]" || die "Cannot open the file '$ARGV[0]'.\n";
}
while(<F>)
{
	chomp;
	my @sp=split(/\t/,$_);
	if($_=~/^Gene\t/)
	{
		print OUT "$_\n";
	}
	elsif($_ ne "" && $sp[6]<=1e-5)
	{
		print OUT "$_\n";
	}
}
close F;
close OUT;
