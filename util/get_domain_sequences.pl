#! /usr/bin/perl -w
use strict;
use warnings;

if(@ARGV!=3)
{
	print "\nperl $0 <selected Pfam ID list> <domain.tab> <protein-coding gene aa sequences>\n";
	exit;
}

# selected Pfam ID list
# PF00657
# PF13472

# domain.tab
# PITG_00712           -            328 Lipase_GDSL_2        PF13472.1    179   1.1e-26   94.3   0.0   1   1   1.2e-29   1.4e-26   93.9   0.0     3   179    70   267    68   267 0.91 -
# PITG_00927           -            282 Lipase_GDSL_2        PF13472.1    179   2.8e-26   93.0   0.3   1   1   3.1e-29   3.7e-26   92.6   0.3     3   178    44   238    42   239 0.86 -

my %domainID;
open D,"$ARGV[0]" || die "Cannot open the file '$ARGV[0]'.\n";
while(<D>)
{
	chomp;
	my @sp=split(/\s+/,$_);
	if($_ ne "")
	{
		$domainID{$sp[0]}=1;
	}
}
close D;

my %seq;
open S,"$ARGV[2]" || die "Cannot open the file '$ARGV[2]'.\n";
$/=">";
<S>;
$/="\n";
while(<S>)
{
	my $id=(split(/\s+/,$_))[0];
	$/=">";
	$seq{$id}=<S>;
	$seq{$id}=~s/>$//;
	$seq{$id}=~s/\s+//g;
	$/="\n";
}
$/="\n";
close S;

my %selectedseq; # select the domain annotation with the minimum E-value 
open T,"$ARGV[1]" || die "Cannot open the file '$ARGV[1]'.\n";
while(<T>)
{
	chomp;
	my @sp=split(/\s+/,$_);
	if($_ ne "" && !($_=~/^#/))
	{
		$sp[4]=(split(/\./,$sp[4]))[0];
		my $domainseq=substr($seq{$sp[0]},$sp[17],$sp[18]-$sp[17]+1);
		if(defined $domainID{$sp[4]} && !(defined $selectedseq{$sp[0]}) && $sp[12]<=1e-5)
		{
			$selectedseq{$sp[0]}{"seq"}=$domainseq;
			$selectedseq{$sp[0]}{"evalue"}=$sp[12];
		}
		elsif(defined $domainID{$sp[4]} && defined $selectedseq{$sp[0]} && $sp[12]<$selectedseq{$sp[0]}{"evalue"})
		{
			$selectedseq{$sp[0]}{"seq"}=$domainseq;
			$selectedseq{$sp[0]}{"evalue"}=$sp[12];
		}
	}
}
close T;

foreach my $id(sort keys %selectedseq)
{
	print ">$id\n".($selectedseq{$id}{"seq"})."\n";
}


__END__
