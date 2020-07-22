use strict;

use feature 'switch';

use feature 'say';

use File::Basename;

use Cwd;

#removes warning for experimental switch function on later versions
no if ($] >= 5.018), 'warnings' => 'experimental';	

#decompresses file based on extension
sub decompress {
	my ($file) = @_;
	my ($name,$path,$extension) = fileparse($file, qr"\..[^.]*$");
	my @arguments;
	if ($extension eq '.gz') {
		push @arguments, ("gunzip", "-c", $file);
		$file = substr($file, 0, -3);
	} elsif ($extension eq '.Z') {
		push @arguments, ("uncompress", "-k", $file);
		$file = substr($file, 0, -2);
	} elsif ($extension eq '.bz2') {
		push @arguments, ("bzip2", "-d", "-k", $file);
		$file = substr($file, 0, -4);
	}
	system(@arguments);
	return $file;
}

#extracts file with duplicates deleted
sub deleteDups {
	my ($file) = @_;
	my @arguments =("tar", "-xvf", $file);
	system(@arguments);
}

#creates a soft link to duplicate files
sub softLink {
	my ($file) = @_;
	say $file;
	my @arguments = ("tar", "-xvf", $file);
	system(@arguments);
	@arguments = ();
	my @duplicates = getDuplicates();
	my $pair;
	foreach $pair (@duplicates) {
		push @arguments, ("ln", "-s", cwd() . "/" . $pair->[0], $pair->[1], "&&");
	}
	pop @arguments;
	my $command = join(" ", @arguments), "\n";
	system($command);
}

#copies duplicate files as they were originally
sub copyDups {
	my ($file) = @_;
	my @arguments = ("tar", "-xvf", $file);
	system(@arguments);
	@arguments = ();
	my @duplicates = getDuplicates();
	my $pair;
	foreach $pair (@duplicates) {
		push @arguments, ("cp", $pair->[0], $pair->[1], "&&");
	}
	pop @arguments;
	system(@arguments);
}

#fetches duplicate list from duplicates.txt
sub getDuplicates {
	open my $dupFile, "<", "duplicates.txt";
	my @pair;
	my @duplicates;
	my $count = 0;
	while (my $line = <$dupFile>) {
		@pair = split ' ', $line;
		push @{$duplicates[$count]}, @pair;
		$count++;
	}
	close ($dupFile);
	return @duplicates;
}




my $argCount = $#ARGV + 1;	#number of arguments provided
if ($argCount > 0) {
	my $method = 'default';

	#checks for option and removes from arguments once retrieved
	if (substr($ARGV[0], 0, 1) eq '-') {
		$method = substr($ARGV[0], 1, 1);
		splice @ARGV, 0, 1;
		$argCount--;
	}

	#ensures correct amount of arguments
	if ($argCount < 1) {
		die "Not enough arguments provided.\n Command should be in format \"undear [options] file\"";
	} elsif ($argCount > 1) {
		die "Too many arguments provided.\n Command should be in format \"undear [options] file\"";
	}


	my $file = $ARGV[0];
	$file = decompress($file);

	#determines how duplicates should be treated
	given($method){
		when('d') {deleteDups($file);}
		when('l') {softLink($file);}
		when('c') {copyDups($file);}
		default {die "No option specified.";}
		}
	system("rm duplicates.txt");
	system("rm test.tar");
	}
else {
	die "No arguments provided.\n";
}

