#!/usr/bin/perl -w
use Bio::SeqIO;
use List::Util qw(max min);

my ($coords) = @ARGV;

unless($coords){print STDERR "\nUseage: perl $0 <coords>\n\n";exit}

my $min_cov = 0.5;

open COR,$coords || die;
while(<COR>){
	next if $. < 5;
	chomp;
	my @s = split;
	next if $s[6] < 90;
	$info{$s[-1]} = $s[8];
	$info{$s[-2]} = $s[7];
	push @{$hash{$s[-1]}{$s[-2]}},[$s[0],$s[1],$s[2],$s[3]];
	
}
close COR;

my($ref_span,$ref_strand,$ref_pos,$qry_span,$qry_strand,$qry_pos);

foreach $scaf(keys %hash){
	my $tmp_span = 0;
	foreach $chr(keys %{$hash{$scaf}}){
		my @ref = ();
		my @qry = ();
		foreach(@{$hash{$scaf}{$chr}}){
			push @ref,[$_->[0],$_->[1]];
			push @qry,[$_->[2],$_->[3]];
		}
		
		($ref_span,$ref_strand,$ref_pos) = span_size(\@ref);
		($qry_span,$qry_strand,$qry_pos) = span_size(\@qry);
		
		print $info{$scaf},"\t",$chr,"\t",$qry_span,"\n";
		next if $qry_span / $info{$scaf} < $min_cov;
		
		if($qry_span > $tmp_span){
			$res{$scaf} = {'chr'=>$chr,'strand'=>$qry_strand,'pos'=>$ref_pos};
			$tmp_span = $qry_span;
		}
	}
}


foreach(keys %res){
	$final{$res{$_}->{'chr'}} += $info{$_};
}


foreach(sort keys %final){print $_,"\t",$final{$_},"\n"}



sub span_size{
	my $data = shift;
	my @new = ();
	my $pos = 0;
	my $neg = 0;
	my ($strd,$mid);
	my $ck = 0;
	
	my @sorted =
			map  { $_->[0] }
			sort{$a->[1] <=> $b->[1]}
			map  { [$_, min(@$_)] } 
			@$data;

	foreach $a(@sorted){
		my $min = min @$a;
		my $max = max @$a;
		if($a->[0] < $a->[1]){
			$pos += $a->[1] - $a->[0] + 1;
			if($a->[1] - $a->[0] + 1 > $ck){
				$mid = ($a->[1] + $a->[0]) /2 ;
				$ck = $a->[1] - $a->[0] + 1;
			}
		}
		else{
			$neg += $a->[0] - $a->[1] + 1 ;
			if($a->[0] - $a->[1] + 1 > $ck){
				$mid = ($a->[1] + $a->[0]) /2 ;
				$ck = $a->[0] - $a->[1] + 1;
			}
		}
		
		if(!@new){push @new, ($min,$max)}
		else{
			if($min <= $new[-1]){
				$new[-1] = max($max,$new[-1]);
			}
			else{push @new,($min,$max)}
		}
	}
	my $size = 0 ;
	while(my @s = splice(@new,0,2)){
		$size += $s[1] - $s[0] + 1;
	}
	
	$strd = $pos > $neg ? "+" : "-";
	
	return($size,$strd,$mid);
}



