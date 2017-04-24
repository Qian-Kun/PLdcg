#! /usr/bin/perl -w
use strict;
use warnings;

if(@ARGV!=3)
{
	print "\nperl $0 <CE_domain_infor.txt> <out.step3> <output>\n";
	exit;
}

# CE_domain_infor.txt
# PF00756	CE1	ET	Esterase

my %class;
open C,"$ARGV[0]" || die "Cannot open the file '$ARGV[0]'.\n";
while(<C>)
{
	chomp;
	my @sp=split(/\t/,$_);
	if($_ ne "")
	{
		$class{$sp[0]}="$sp[1]\t$sp[2]\t$sp[3]";
	}
}
close C;

# PITG_12361	PF01083.17	Cutinase	1.6e-51	2e-51	Cutinase
my %gene;
open G,"$ARGV[1]" || die "Cannot open the file '$ARGV[1]'.\n";
while(<G>)
{
	chomp;
	my @sp=split(/\t/,$_);
	if($_ ne "")
	{
		$sp[1]=(split(/\./,$sp[1]))[0];
		if(defined $class{$sp[1]})
		{
#			my @gsp=split(/\t/,$class{$sp[1]});
			$gene{$sp[0]}{$sp[1]}=$class{$sp[1]};
		}
	}
}
close G;

open OUT,">$ARGV[2]";
foreach my $id(sort keys %gene)
{
	my $opfam="";
	my $oclass="";
	my $ofunction="";
	my $odescription="";
	my %repeat;
	foreach my $pid(sort keys %{$gene{$id}})
	{
		my @gsp=split(/\t/,$gene{$id}{$pid});
		$opfam.="$pid\;";
		my @osp=split(/\;/,$gsp[1]);
		if(!(defined $repeat{$gsp[1]}))
		{
			$repeat{$gsp[1]}=1;
			$oclass.="$gsp[0]\;";
			$ofunction.="$gsp[1]\;";
			$odescription.="$gsp[2]\;";
		}
	}
	$opfam=~s/\;$//;
	$oclass=~s/\;$//;
	$ofunction=~s/\;$//;
	$odescription=~s/\;$//;
	print OUT "$id\t$opfam\t$oclass\t$ofunction\t$odescription\n";
}
close OUT;


__END__
