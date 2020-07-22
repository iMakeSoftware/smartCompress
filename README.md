README

Filename: dear.pl

Description: Creates a compressed archive where any duplicates found are not included but instead stored in a reference text file called "duplicates.txt" within the archive.

Usage: perl dear.pl [options] <outfile> <indir>

Options:

	Allows a compression method to be specified:
		
		-g: Uses gzip

		-b: Uses bzip2

		-c: Uses compress (LZW)


Filename: undear.pl

Description: Uncompresses based on file extension and then unarchives using tar

Usage: perl undear.pl [options] <file>

Options:

	Decides treatment of duplicate files:
		
		-d: Delete duplicate files

		-l: Create soft link in place of duplicate file

		-c: Copy duplicate files as they were originally



Filename: fdupes.sh

Description: Bash script used in dear.pl to find duplicate files