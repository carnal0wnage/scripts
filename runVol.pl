#!/usr/bin/perl -ws
# Joe's Automatic Volatility Analysis Script
# Usage: runVol.pl <memory file to analyze>
# 
# To Do: 
#   * Modify initial analysis to detect multi-core or multi-processor machines
#   *

## Global Variables
my $python = "/usr/bin/python";
my $volPath = "/home/barrettj/code/Volatility/vol.py";
my $sample = "";
my $profile = "";
my @plugins = qw(pslist pstree psscan dlllist handles getsids cmdscan consoles enumfunc modules modscan ssdt driverscan filescan mutantscan symlinkscan thrdscan connections connscan sockets sockscan netscan hivescan hivelist shellbags shimcache mftparser malfind svcscan lrdmodulues apihooks idt gdt threads callbacks driverirp devicetree psxview timers);

# Getting command line arg
if( $#ARGV == 0 ) {
  $sample = $ARGV[0];
  if( -e $sample ) {
    # File is good 
  } else {
    print "Error: file $sample does not exist or is not readable\n";
    exit;
  }
  main();
} else {
  print "Usage: runVol.pl <memory file>\n";
}
exit;

# Main program run
sub main {
  print "Running analysis on file '$sample'...\n\n";
  getProfile();
  runPlugins();
}

# Figures out what operating system and profile we should use for the rest of the plugins
sub getProfile { 
  my @o = `$python $volPath -f $sample imageinfo` ; 
  foreach my $line (@o) {
    if( $line =~ /Suggested Profile\(s\) : ([a-zA-Z0-9]+)/ ) {
      print "* Guessing profile $1\n";
      $profile = $1;
    }
  }
  system( "mkdir -p analysis" ); # We save our output in here
}

# Runs each plugin in sequence and saves the output
sub runPlugins {
  foreach my $plugin (@plugins) {
    print "* Running plugin $plugin...";
    my $opts = "";
# Some plugins require additional configuration
    if( $plugin =~ /enumfunc/ ) {
      $opts = "-P -E"; # Process Exports
      my @o = `$python $volPath -f $sample --profile=$profile --output-file=analysis/$sample-$plugin-procExp.txt $plugin $opts`;
      $opts = "-K -I"; # Kernel Imports
      my @o = `$python $volPath -f $sample --profile=$profile --output-file=analysis/$sample-$plugin-kernImp.txt $plugin $opts`;
    } else {
      my @o = `$python $volPath -f $sample --profile=$profile --output-file=analysis/$sample-$plugin.txt $plugin`;
    }
  }
}




