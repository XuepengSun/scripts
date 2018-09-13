#!/usr/bin/perl -w
use File::Find;
use Statistics::R;

my $DirWithKO = 'KO';
my @f = glob("$DirWithKO/*.txt");
my $outputNum = 'tmp_ko_absNum.txt';
my $outputPA = 'tmp_ko_PA.txt';

foreach(@f){
	my ($id)=$_=~/.*\/(.*?)\./;
	open IN,$_ || die;
	while(<IN>){
		chomp;
		$data{$id}{$_} ++;
		$list{$_}= 1;
	}
	close IN;
}

open A,">$outputNum";
open B,">$outputPA";

print A "ko";
print B "ko";
foreach(sort keys %data){
	print A "\t",$_;
	print B "\t",$_;
}
print A "\n";
print B "\n";

foreach $i(keys %list){
	print A $i;
	print B $i;
	foreach(sort keys %data){
		$data{$_}{$i} //= 0;
		print A "\t",$data{$_}{$i};
		if($data{$_}{$i} > 0){
			print B "\t", 1;
		}
		else{print B "\t",0}
	}
	print A "\n";
	print B "\n";
}
close A;
close B;



