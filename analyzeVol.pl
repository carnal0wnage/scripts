#!/usr/bin/perl -ws
#
# Joe's Volatility Output Analysis Script
# * takes the mem-plugin.txt files output from runVol.pl
#   and performs triage-level analysis looking for glaringly bad things

# Usage: analyzeVol.pl <memory file>
# * Opens up the analysis directory and looks for analysis/mem-*.txt
# * For each plugin, we'll have a list of things to look for


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

}

# Plugin(s): svcscan
# Look for services started in unusual locations (i.e.: not system32)
# Ideally: build a whitelist of known-good services and identify all others
sub svcscan {

}

# Plugin(s): ldrmodules
# Look for modules that are hidden in one or more ways
sub ldrmodules {

}

# Plugin(s): apihooks
# Look for kernel mode hooks, display the type of hook, victim module and hooking module
sub apihooks {

}

# Plugin(s): idt
# Look for badness (ntoskrnl.exe with a non-.text segment, etc.)
sub idt {

}

# Plugin(s): gdt
# Look for callgates, etc.
sub gdt {

}

# Plugin(s): callbacks
# Look for potentially suspicious callbacks
sub callbacks {

}# Plugin(s): callbacks
# Look for potentially suspicious callbacks
sub callbacks {

}

# Plugin(s): callbacks
# Look for potentially suspicious callbacks
sub callbacks {

}

# Plugin(s): psxview
# Look for processes that are hidden in one or more ways
sub psxview {

}

# Plugin(s): timers
# Look for timers hidden in strange parts of memory, etc.
sub timers {

}




