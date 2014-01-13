#!/usr/bin/env ruby
# 
# Network Integrity Test v0.1
# 
# Take a PCAP file and carve out unique endpoints, build diagram
# Then carve out conversations and figure out what hosts are listening where
require "awesome_print"
require "win32ole"
require "win32API"

class VisioConst
# Empty class to hold constants
end

@endpoints = Hash.new
@ports = Hash.new
@conversations = Hash.new

# Used to manipulate windows using Win32 API
def ShowWindow( wndHandle, cmd )
	wndShowWindow = Win32API.new("user32", "ShowWindow", ["p","i"], "i" )
	wndShowWindow.call( wndHandle, cmd )
end

def getAbsolutePathName( file )
	fso = WIN32OLE.new('Scripting.FileSystemObject')
	return fso.GetAbsolutePathName( file )
end

# Parses the text looking for endpoints
def findEndpoints( text )
  text.lines.each do |line| 
    line = line.chomp
    if( line =~ /^(\d+\.\d+\.\d+\.\d+)\s+<\->\s+(\d+\.\d+\.\d+\.\d+)\s+/ )
      addEndpoint( $1 )
      addEndpoint( $2 )
    end
  end
#  printEndpoints
end

# Parses the text looking for ports and conversations
def findConversations( text )
  text.lines.each do |line|
    line = line.chomp
    if( line =~ /^(\d+\.\d+\.\d+\.\d+:\d+)\s+<\->\s+(\d+\.\d+\.\d+\.\d+:\d+)/ )
      addPort( $1 )
      addPort( $2 )
      addConversation( $1, $2 )
      addConversation( $2, $1 )
    end
  end
#  printPorts
#  printConversations
end


### Hash Add Functions ###

def addConversation( source, dest )
  if( @conversations.key?( source ) ) # If this source already exists
    @conversations[source].push(dest)
  else
  # If the source doesn't exist, we need to add it
    @conversations[source] = Array.new
    @conversations[source].push(dest)
  end
end

# Add an endpoint to the graph - bonus, track how many times each endpoint was found talking to unique IPs
def addEndpoint( endpoint )
  if( @endpoints.key?( endpoint ) )  # Already exists
    @endpoints[endpoint] += 1
  else
    @endpoints[endpoint] = 1
  end
end

# Add an active port to the list
def addPort( port )
  if( @ports.key?( port ) )  # Already exists
    @ports[port] += 1
  else
    @ports[port] = 1
  end
end


### Print Functions ###

def printEndpoints
  ap @endpoints, options = { :sort_keys => true }
end

def printPorts
  ap @ports, options = { :sort_keys => true }
end

def printConversations
  ap @conversations, options = { :sort_keys => true }
end

### Draw Functions ###
def drawEndpoints( page, stencil )
  i = 0
  j = 0
  @endpoints.each do |k,v| 
    shape1 = page.Drop( stencil, i, j) # inches from lower left corner of document page
    shape1.Text = k
#    p shape1.Connects
    @endpoints[k] = shape1
    if( i < 8 )
      i += 1
    else
      j += 1
      i = 0
    end
  end
end

# Draw the two endpoints of the conversation and a connection between
def drawConversations( page, stencil )
  i = 0
  j = 0
  @conversations.each do |k,v|
    shape1 = page.Drop( stencil, i, j) # inches from lower left corner of document page
    shape1.Text = k
    v.each do |other|
      shape2 = page.Drop( stencil, i, j+1 )
      shape2.Text = other

# Print out all of the OLE methods for this object
#     ap shape2.ole_methods.collect! { |e| e.to_s }.sort

# Create the connector object
      conn = @stencil.Masters("Dynamic Connector")
# Link the two shapes with a connector, 0 = no arrows/direction
      shape2.AutoConnect( shape1, 0, conn )
      
    end
    if( i < 10 )
      i += 2
    else
      j += 2
      i = 0
    end
  end
# Center on our stuff
  page.CenterDrawing
end

### Main Program Flow ### 
file = ARGV[0]
if( ! File.exists?( file ) )
  print "#{file} doesn't exist.\n"
  exit
end

# Getting the list of IP conversations
output = `tshark -r #{file} -q -z conv,ip`
findEndpoints( output )

output = `tshark -n -r #{file} -q -z conv,tcp`
findConversations( output )

# Get the Visio handle
visio = WIN32OLE.new('Visio.Application')
# Load in Constants
WIN32OLE.const_load( visio, VisioConst )

docs = visio.Documents
mydoc = docs.Add("Detailed Network Diagram.vst") 

#ShowWindow(visio.WindowHandle32, 3) # maximizes the Visio window
visio.ActiveWindow.Zoom = 1 # Zoom to 100%

# Grab a handle to the page
page = visio.ActiveDocument.Pages.Item(1)

# Grab a stencil
@stencil = visio.Documents("Servers.vss")
#@connects = visio.Documents("CONNEC_U.vss")
server1 = @stencil.Masters("Server")

# Draw the endpoints using the page handle and the given shape
#drawEndpoints( page, server1 )
drawConversations( page, server1 )


# Save the file out to current directory
filename = getAbsolutePathName("#{Dir.pwd}/Demo1.vsd")
visio.ActiveDocument.SaveAsEx( filename, VisioConst::VisSaveAsWS + VisioConst::VisSaveAsListInMRU)



