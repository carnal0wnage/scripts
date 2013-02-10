#!/usr/bin/perl -ws
#
# Joe's Volatility Output Analysis Script
#   takes the mem-plugin.txt files output from runVol.pl
#   and performs triage-level analysis looking for glaringly bad things

# Usage: analyzeVol.pl <memory file>
# * Opens up the analysis directory and looks for analysis/mem-*.txt
# * For each plugin, we'll have a list of things to look for

my $sample = "";

if( $#ARGV == 0 ) {
  $sample = $ARGV[0];
  main();
} else {
  print "Usage: runVol.pl <memory file>\n";
}
exit;

# Call each of the analysis functions in turn. Order? Bah, who cares what order it's in?
sub main {
  ssdt();
  timers();
  gdt();
  idt();
  callbacks();
  svcscan();
  apihooks();
  psxview();
}

# Plugin(s): pslist
# * Looking for all processes with potentially suspicious parents
# * PPID = 4 [system]
# * parent = smss.exe, csrss.exe, wininit.exe, winlogon.exe, lsass.exe, 
sub pslist {

}

# Plugin(s): modules, modscan
# We should run modules with -P to get physical addresses, then compare to modscan
# Looking for modules that don't show up in one or the other
sub modules {

}

# Plugin(s): ssdt
# Look for entries in the SSDT not owned by ntoskrnl.exe or win32k.sys
sub ssdt {
  my $file = "./analysis/$sample-ssdt.txt";
  open( SSDT, "$file" ) || return;
  while( <SSDT> ) {
    my $line = $_;
    chomp $line;
    if( $line =~ /ntoskrnl.exe/ ) {
      # Ignore
    } elsif( $line =~ /win32k.sys/ ) {
      # Ignore
    } else {
      print "SSDT: $line\n";
    }
  }
  close( SSDT );
}

# Plugin(s): svcscan
# Look for services started in unusual locations (i.e.: not system32)
# Ideally: build a whitelist of known-good services and identify all others
sub svcscan {
  my $file = "./analysis/$sample-svcscan.txt";
  open( SVCSCAN, "$file" ) || return;
  my $svc = "";
  while( <SVCSCAN> ) {
    my $line = $_;
    chomp $line;
    if( $line =~ /Service Name: (.*)/ ) {
      $svc = $svc . "SVCSCAN: Service Name: $1\n";
    } elsif( $line =~ /Service Type: (.*)/ ) {
      $svc = $svc . "SVCSCAN: Service Type: $1\n";
    } elsif( $line =~ /Binary Path: (.*)/ ) {
      $bin = $1;
      if( $bin =~ /^\-$/ ) {
        # No path
      } elsif( $bin =~ /windows.*system32/i ) {
        # System32 doesn't mean trusted, but this is triage analysis.
      } else {
        $svc = $svc . "SVCSCAN: Binary Path: $1\n\n";
        print "$svc";
      }
      $svc = "";
    }
  }
  close( SVCSCAN );

}

# Plugin(s): ldrmodules
# Look for modules that are hidden in one or more ways
sub ldrmodules {

}

# Plugin(s): apihooks
# Look for kernel mode hooks, display the type of hook, victim module and hooking module
sub apihooks {
  my $file = "./analysis/$sample-apihooks.txt";
  open( APIHOOKS, "$file" ) || return;
  my $hook = "";
  my $type = "";
  while( <APIHOOKS> ) {
    my $line = $_;
    chomp $line;
    if( $line =~ /Hook mode: (.*)/ ) {
      $hook = $hook . "APIHOOKS: Hook Mode: $1\n";;
      if( $1 =~ /kernel/i ) {
        $type = "k";
      } else {
        $type = "u";
      }
    } elsif( $line =~ /Hook type: (.*)/ ) {
      $hook = $hook . "APIHOOKS: Hook Type: $1\n";;
    } elsif( $line =~ /Victim module: (.*)/ ) {
      $hook = $hook . "APIHOOKS: Victim Module: $1\n";;
    } elsif( $line =~ /Hooking module: (.*)/ ) {
      $bin = $1;
      $hook = $hook . "APIHOOKS: Hooking module: $1\n\n";
#      if( $type eq "k" ) { # If we decide we only want to print kernel-mode API hooks, this is where we do it.
        print "$hook";
        #     }
      $hook = ""; $type = "";
    }
  }
  close( APIHOOKS );

}

# Plugin(s): idt
# Look for badness (ntoskrnl.exe with a non-.text segment, etc.)
sub idt {
  my $file = "./analysis/$sample-idt.txt";
  open( IDT, "$file" ) || return;
  while( <IDT> ) {
    my $line = $_;
    chomp $line;
    if( $line =~ /ntoskrnl.exe[ \t]+.text/i ) {
# Ignore
    } elsif( $line =~ /hal.dll[ \t]+.text/i ) {
# Ignore
    } elsif( $line =~ /[a-fA-F0-9]+[ \t]+UNKNOWN/i ) {
# Ignore
    } else {
      print "IDT: $line\n";
    }
  } 
  close( IDT );
}

# Plugin(s): gdt
# Look for callgates, etc.
sub gdt {
  my $file = "./analysis/$sample-gdt.txt";
  open( GDT, "$file" ) || return;
  while( <GDT> ) {
    my $line = $_;
    chomp $line;
    if( $line =~ /callgate/i ) {
      print "GDT: $line\n";
    }
  } 
  close( GDT );
}

# Plugin(s): callbacks
# Look for potentially suspicious callbacks
sub callbacks {
  my $file = "./analysis/$sample-callbacks.txt";
  open( CALLBACKS, "$file" ) || return;
  while( <CALLBACKS> ) {
    my $line = $_;
    chomp $line;
    if( $line =~ /^([a-zA-Z]+)[ \t]+(0x[0-9A-Fa-f]+)[ \t]+([a-zA-Z0-9\.]+)[ \t]+(.*)$/i ) {
      my $callbackFunction = $1;
      my $callbackAddr = $2;
      my $module = $3;
      my $details = $4;
      if( $module =~ /driver/i ) {
        print "CALLBACKS: $line\n";
      } elsif( $module =~ /unknown/i ) { # Callbacks to unknown modules
        print "CALLBACKS: $line\n";
      } elsif( $module =~ /([0-9a-fA-F]+){8}/i ) { # Black Energy 2's module name = 8 hex characters
        print "CALLBACKS: $line\n";
      }
    }
  } 
  close( CALLBACKS );
}

# Plugin(s): psxview
# Look for processes that are hidden in one or more ways
sub psxview {
  my $file = "./analysis/$sample-psxview.txt";
  open( PSXVIEW, "$file" ) || return;
  while( <PSXVIEW> ) {
    my $line = $_;
    chomp $line;
    if( $line =~ /Offset/i ) {
      print "PSXVIEW: $line\n";
    } elsif( $line =~ /false/i ) {
      print "PSXVIEW: $line\n";
    }
  } 
  close( PSXVIEW );

}

# Plugin(s): timers
# Look for timers hidden in strange parts of memory, etc.
sub timers {
  my $file = "./analysis/$sample-timers.txt";
  open( TIMERS, "$file" ) || return;
  while( <TIMERS> ) {
    my $line = $_;
    chomp $line;
    if( $line =~ /unknown/i ) {
      print "TIMERS: $line\n";
    }
  } 
  close( TIMERS );
}




