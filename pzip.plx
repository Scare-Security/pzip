#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Term::ANSIColor qw( :constants );
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
Archive::Zip::setErrorHandler( sub{
    die "error with the zip archive: $!\n";
} ); # turn off default error msgs

my $usage = "usage: $0 -f [zip file] -w [wordlist]\n";
GetOptions (
    'file=s' => \my $zipfile,
    'wordlist=s' => \my $wordlist,
) or die $usage;
die $usage unless(defined($zipfile) && defined($wordlist));

# open the zip file and the wordlist
open my $WORDLIST, '<', $wordlist
    or die "couldn't open wordlist: $!\n";

# try all password
my $found = 0;
my $pwd;
while(defined($pwd = <$WORDLIST>)) {
    chomp $pwd;

    my $zip = Archive::Zip->new;
    $zip->read($zipfile);
    
    my $file = $zip->memberNamed(($zip->memberNames)[0]);
    $file->password($pwd);
    
    if($file->contents ne "") {
        $found = 1;
        last;
    }
    warn BLUE, "[\$] trying $pwd", RESET, "\n";
}

print GREEN, "[+] password found: $pwd\n", RESET if $found;
print RED, "[-] password not found..\n", RESET if !defined($pwd);
