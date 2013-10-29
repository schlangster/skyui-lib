#!/usr/bin/perl

use File::Basename;
use File::Copy;
use File::Path;

sub error
{
	print	"\n=========================\n\n"
		.	"ERROR: $_[0]\n";
	getc(STDIN);
	exit(1);
}

sub copyFile
{
	mkpath(dirname($_[1]));
	if (copy($_[0], $_[1])) {
		print "Copy $_[0] to $_[1]\n";
	} else {
		print "SKIP $_[0]\n";
	}
}

$skyrimPath			= $ENV{'SkyrimPath'} or error("\$SkyrimPath env var not set.");
$scriptPath			= $skyrimPath . "\\Data\\Scripts\\Source";
$compilerPath		= $skyrimPath . "\\Papyrus Compiler\\PapyrusCompiler.exe";
$compilerFlagPath	= $scriptPath . "\\TESV_Papyrus_Flags.flg";

# Safety check
error("Do not run this script in the vanilla scripts folder!") if (-e "Data\\Scripts\\Source\\TESV_Papyrus_Flags.flg");

# No wait?
$noWait = defined($ARGV[0]);

# Clean old files
unlink($_) foreach (<Data/Scripts/*.pex>);

# Compile files in Source/
@argList = (
	"$compilerPath",
	"..\\src-papyrus",
	"-i=..\\src-papyrus; $scriptPath",
	"-o=$skyrimPath\\Data\\Scripts",
	"-f=$compilerFlagPath",
#	"-op",
	"-all"
);
	
system(@argList) == 0 or error("Compile failed.");

getc(STDIN) unless $noWait;
exit(0);