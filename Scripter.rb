#!/usr/bin/ruby
#
# The purpose of this is to ensure that our actions while on a pentest are logged properly
# Each shell window should be scripted out to the right location

require 'process'

opsdir = "/DATA/current/op"

system( "mkdir -p #{opsdir}" ) # Ops is our log location

# Get the date and time
d = Time.now.to_i
# Get the shell's process id
ppid = Process.ppid

# Print the command to run:
print "**** Copy and Paste the below for a scripted window ****\n\n"

print "/usr/bin/script -a #{opsdir}/script-#{d}_pid#{ppid}.txt\n"
print "export PS1=\"%{$fg[red]%}[SCRIPTED]%{$reset_color%} $PS1\"\n"
# Other environment variables we should build:
# * ops directory where metasploit/armitage logs end up
# * 
# 

print "\n\n**** End C&P Block ****\n"

# 
