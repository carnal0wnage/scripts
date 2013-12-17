#!/usr/bin/env ruby

# Parse the gnmap file looking for nfs servers
def parse( filename )
  File.readlines( "#{@dir}/#{filename}" ).each do |line|
    if( line =~ /Host: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*\/nfs\//i )
      server = $1
      print "Found NFS server: #{server}\n"
      showmount( server )
    end
  end
end

# Show all mounts on a given server
def showmount( server )
  output = `showmount -e #{server}`
  output.lines.map(&:chomp).each do |line|
    if( line =~ /(.*)\s+.*everyone/i )
      share = $1.squeeze(" ")
      print "#{server} is exporting #{share} to everyone\n"
      mount( server, share )
    end
  end
end


# Mount a share, trawl the filesystem
def mount( server, share )
  system( "mount -t nfs -o nolock #{server}:#{share} /mnt/test" )
  name = share.gsub("/","_").gsub(" ","")
  print( "Now searching: find /mnt/test > ~/Foreground/Ops/nfsfind-#{server}-#{name}.txt\n" )
  system( "find /mnt/test > ~/Foreground/Ops/nfsfind-#{server}-#{name}.txt" )
  system( "umount /mnt/test" )
end

# Takes the target directory as an argument
@dir = ARGV[0].to_s.chomp
if( Dir.exists?(@dir) )
  print "Searching gnmap results in #{@dir}\n"
else
  print "#{@dir} is not a valid directory, quitting...\n"
  exit
end

# Get all gnmap results in the directory
files = Dir.entries( @dir )
files.each do |f|
  if( f =~ /.*gnmap/ )
    print "Found #{f}, parsing...\n"
# This is a gnmap file, parse it for NFS servers
    parse( f )
  else
    # Skip
  end
end


