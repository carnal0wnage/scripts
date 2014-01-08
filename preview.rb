#!/usr/bin/env ruby
# 
# Takes a markdown-formatted file, renders as HTML, and launches dillo to view it
require 'redcarpet'
require 'tempfile'

# For each file on the command line, render and display
ARGV.each do |f|
  if( File.exist?(f) )
    # Create the markdown renderer
    m = Redcarpet::Markdown.new( Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
    # Read the file contents
    fh = File.open( f, "r" )
    # Render them as HTML
    output = m.render( fh.read )
    # Create temporary file
    t = Tempfile.new("md")
    # Write to temporary file
    t.write( output )
    # flush buffer
    t.flush
    # Display file with browser
    system "firefox #{t.path}"
    # Close temp file to destroy
    t.close
  else
    print "File #{f} does not exist or could not be read.\n"
  end
end


