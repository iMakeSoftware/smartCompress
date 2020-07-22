use strict;

use feature 'switch';

use feature 'say';

use File::Basename;

#removes warning for experimental switch function on later versions
no if ($] >= 5.018), 'warnings' => 'experimental';	

#compresses using gzip program
sub gzipCompress {
	my ($file) = @_;
	system("gzip", $file);
}

#compresses using bzip2 program
sub bzip2Compress {
	my ($file) = @_;
	system("bzip2", $file);
}

#compresses using compress program
sub LZWCompress {
	my ($file) = @_;
	system("compress", $file);
}

#Uses tar to create archive
sub archive {
	my ($outfile, $indir, @duplicates) = @_;
	my @arguments = ("tar");
	foreach my $duplicate (@duplicates) {
		push @arguments, ("--exclude", $duplicate);
	}
	push @arguments, ("-cvf", $outfile, $indir, "duplicates.txt");
	system(@arguments);
}

#	Finds all duplicates by first searching for matching filenames and then checking 
#	md5 hash

sub findDuplicates {
	my ($directory) = @_;
	my @files = <*>;
	system("sh", "fdupes.sh", $directory);
}

my $argCount = $#ARGV + 1;	#number of arguments provided
if ($argCount > 1) {
	my $method = 'default';

	#checks for compression option and removes from arguments once retrieved
	if (substr($ARGV[0], 0, 1) eq '-') {
		$method = substr($ARGV[0], 1, 1);
		splice @ARGV, 0, 1;
		$argCount--;
	}

	#ensures correct amount of arguments
	if ($argCount < 2) {
		die "Not enough arguments provided.\n Command should be in format \"dear [options] outfile indir\"";
	} elsif ($argCount > 2) {
		die "Too many arguments provided.\n Command should be in format \"dear [options] outfile indir\"";
	}

	my $outfile = $ARGV[0];
	my $indir = $ARGV[1];
	findDuplicates($indir);

	open my $unFilteredFile, "<", "unfilteredDuplicates.txt";
	open my $dupFile, ">", "duplicates.txt";
	my @pair;
	my @duplicates;

	#ensures files with different names are not stored as duplicates
	while (my $line = <$unFilteredFile>) {
		@pair = split ' ', $line;
		my ($name1,$path1,$extension1) = fileparse($pair[0], qr"\..[^.]*$");
		my ($name2,$path2,$extension2) = fileparse($pair[1], qr"\..[^.]*$");
		say $name1, $name2;
		if ($name1 eq $name2) {
			print $dupFile $line;
			push @duplicates, $pair[1];
		}
	}
	close($unFilteredFile);
	close($dupFile);
	system("rm unfilteredDuplicates.txt");
	archive($outfile, $indir, @duplicates); #creates tar file

	#determines which compression program should be used base on option provided
	given($method){
		when('g') {gzipCompress($outfile);}
		when('b') {bzip2Compress($outfile);}
		when('c') {LZWCompress($outfile);}
		default {say "Warning: File not compressed as not compression option was specified.";}
		}
	system("rm duplicates.txt");
	}
else {
	die "No arguments provided.\n";
}

