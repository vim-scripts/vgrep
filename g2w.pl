#!/usr/bin/perl
#
# unixGrep 2 wide 1.00 (perl)
#
# grep option must include -n for line number
#
&viewGrep();
exit 1;

sub viewGrep {
 	$home = $ENV{"HOME"} . "/fte.grp";
 	$homew =">$home";
  	open(FILE, $home) or die "vGrep: No grep founded.\n";
  	@file = <FILE>;
  	close (FILE);
  open (NEWFILE, $homew) or die "$!";
  $lastname='';
  foreach $line (@file) {
	chomp ($line);
	# check meet grep with -n format 
	$line1 = $line;
        if ($line1 =~ /^([^:]*)(:)([^:]*)(:)(.*)/) {
	
#	($fname, $fline, $context) = split(/:/, $line);
	($fname, $fline) = split(/:/, $line);
	$pos = index($line, ":");
	if ($pos) {
		$line2=substr($line,$pos+1);
		$pos = index($line2,":");
		$context = substr($line2,$pos+1);
	}
         if ($lastname ne $fname) {
		print NEWFILE "File: $fname\n";
		$lastname=$fname;
	
	}

	print NEWFILE "$fline:\t";
	print NEWFILE "$context\n";
	}
  }
	close(NEWFILE);
}
 
