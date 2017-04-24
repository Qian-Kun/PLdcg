#! /usr/bin/perl -w
use strict;
use warnings;

if(@ARGV!=3)
{
	print "\nperl $0 <CE annotation file list> <group.txt> <output>\n";
	exit;
}

# file list
# Pin	/Pin/P.infestans_phylogeny_confirm.txt

# P.infestans_phylogeny_confirm.txt
# PITG_06891	PF00756	CE1	ET	Esterase

my %CE;
my %singlegene; # single gene is clustered into one group
open L,"$ARGV[0]" || die "Cannot open the file '$ARGV[0]'.\n";
while(<L>)
{
	chomp;
	my @sp=split(/\t/,$_);
	if($_ ne "")
	{
		open F,"$sp[1]" || die "Cannot open the file '$sp[1]'.\n";
		while(<F>)
		{
			chomp;
			my @gsp=split(/\t/,$_);
			if($_ ne "")
			{
				$CE{$gsp[0]}="$gsp[1]\t$gsp[2]";
				$singlegene{$gsp[0]}=1;
			}
		}
		close F;
	}
}
close L;

my %groupinfor;
open OUT,">$ARGV[2]";
open G,"$ARGV[1]" || die "Cannot open the file '$ARGV[1]'.\n";
while(<G>)
{
	chomp;
	my @sp=split(/\s+/,$_); # PGROUP17518: PS|Physo3_527717 PU|PYU1_T012461
	if($_ ne "")
	{
		chomp;
		my $exist=0; # at least one gene in a group was annotated as CE
		for(my $i=1;$i<@sp;$i++)
		{
			my @gsp=split(/\|/,$sp[$i]);
			$sp[$i]=$gsp[1];
			if(defined $CE{$sp[$i]})
			{
				$exist=1;
				$singlegene{$sp[$i]}=0;
				if(!(defined $groupinfor{$sp[0]}))
				{
					$groupinfor{$sp[0]}=$CE{$sp[$i]};
				}
				else
				{
					my @ispall=split(/\t/,$groupinfor{$sp[0]});
					my @gispID=split(/ /,$ispall[0]);
					my @ispgene=split(/\t/,$CE{$sp[$i]});
					my $repeat=0;
					for(my $j=0;$j<@gispID;$j++)
					{
						if($gispID[$j] eq $ispgene[0])
						{
							$repeat=1;
						}
					}
					if($repeat==0)
					{
						$groupinfor{$sp[0]}="$ispall[0] $ispgene[0]\t$ispall[1] $ispgene[1]";
					}
				}
			}
		}
		my $outgroup=join(" ",@sp);
		if($exist==1)
		{
			print OUT "$outgroup\t$groupinfor{$sp[0]}\n";
		}
	}
}
close G;

my $num=0;
foreach my $id(sort keys %singlegene)
{
	if($singlegene{$id}==1)
	{
		$num++;
		print OUT "Single$num\: $id\t$CE{$id}\n";
	}
}
close OUT;

open GL,">annotated_CE.list";
foreach my $id(sort keys %CE)
{
	print GL "$id\n";
}
close GL;


__END__
