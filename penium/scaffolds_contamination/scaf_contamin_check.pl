#!/usr/bin/perl -w 
use Bio::SeqIO;

my ($scaffolds, $blastnFile, $tax_names, $tax_nodes, $tax_div) = @ARGV;

unless(scalar @ARGV == 5){print STDERR "\nUseage: perl $0 <scaffolds> <blast> <tax_names> <tax_nodes> <tax_division>\n\n";exit}

my $taxid = '33090';         # taxa group to exclude; 33090->Viridiplantae 

open DIV,$tax_div || die;
while(<DIV>){
	my @s = split /\|/;
	$s[0]=~s/^\s+|\s+$//g;
	$s[2]=~s/^\s+|\s+$//g;
	$division{$s[0]}=$s[2];
}
close DIV;

open NAME,$tax_names || die;
while(<NAME>){
	if(/scientific\s+name/){
		my @s = split /\|/;
		$s[0]=~s/^\s+|\s+$//g;
		$s[1]=~s/^\s+|\s+$//g;
		$names{$s[0]}=$s[1];
	}
}
close NAME;

print STDERR "reading $tax_names, done!\n";

open NODE,$tax_nodes || die;
while(<NODE>){
	my @s = split /\|/;
	$s[0]=~s/^\s+|\s+$//g;
	$s[1]=~s/^\s+|\s+$//g;
	$s[4]=~s/^\s+|\s+$//g;
	$nodes{$s[1]}{$s[0]} = 1;
	$division{$s[4]} //= 'not assigned';
	$tax_div_table{$s[0]} = $division{$s[4]};
}
close NODE;

print STDERR "reading $tax_nodes, done!\n";

my @tmp_nodes = ($taxid);

while(@tmp_nodes){
	my $id = shift @tmp_nodes;
	$excluding_taxa{$id} = 1;
	if($nodes{$id}){
		push @tmp_nodes,keys %{$nodes{$id}};
	}
}

print STDERR "excluded taxa: ",scalar keys %excluding_taxa,"\n";


my $num_gaps = 0;
					  
my $io = new Bio::SeqIO(-file=>$scaffolds,-format=>'fasta');
while(my $seq = $io->next_seq){
	my $xl = $seq->seq;
	while($xl=~/[Nn]+/g){
		my $gap_start = length ($`) + 1;
		my $gap_end = length($`) + length($&);
		$gaps{$seq->id}{'left'}{$gap_start} = length($&);
		$gaps{$seq->id}{'right'}{$gap_end} = length($&);
		$num_gaps++;
	}
}
$io->close;

print STDERR "\ntotal gaps: $num_gaps\n\n";

$| = 1;

open BLASTN,$blastnFile || die;
while(<BLASTN>){
	if($. % 100 == 0 ){print STDERR "\rprocessing blastn lines: $."}
	chomp;
	my @s = split;
	next if $s[-6] < 80;
	if (!$blast{$s[0]}{$s[5]}{$s[6]}){
		$blast{$s[0]}{$s[5]}{$s[6]} = $s[-2];
	}
}
close BLASTN;					  
print STDERR "\n";

foreach $scaf(keys %blast){
	foreach $left(sort{$a<=>$b} keys %{$blast{$scaf}}){
		my @sort_right = sort{$b<=>$a} keys %{$blast{$scaf}{$left}};
		next if $excluding_taxa{$blast{$scaf}{$left}{$sort_right[0]}};
		$names{$blast{$scaf}{$left}{$sort_right[0]}} //= "not assigned";
		$tax_div_table{$blast{$scaf}{$left}{$sort_right[0]}} //= "not assigned";
		my $len = $sort_right[0] - $left + 1;
		print $scaf,"\t",$len,"\t",$left,"\t",$sort_right[0],"\t",$tax_div_table{$blast{$scaf}{$left}{$sort_right[0]}},"\t",$blast{$scaf}{$left}{$sort_right[0]},"\t",$names{$blast{$scaf}{$left}{$sort_right[0]}},"\n";
	}
}


