##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'
#require 'pry'

###
#
# This sample auxiliary module simply displays the selected action and
# registers a custom command that will show up when the module is used.
#
###
class Metasploit4 < Msf::Auxiliary

  include Msf::Exploit::Remote::HttpClient
  include Msf::Auxiliary::Scanner

  def initialize(info={})
    super(update_info(info,
      'Name'        => 'websphere_auth_scanner',
      'Description' => 'Websphere Authentication Scanner',
      'Author'      => ['winterspite'],
      'License'     => MSF_LICENSE
    ))
    register_options([
        OptString.new('USER',[false,"User for Auth","notarealadmin"]),
        OptBool.new('AttemptLogin',[false,"Attempt to log in","false"]),
        Opt::RPORT(9060)
      ],self.class)
    deregister_options('Proxies')
    deregister_options('VHOST')
  end

  def run_host(ip)
    begin
      connect

      print_status "Requesting /admin/ to get path to console"
      res = send_request_cgi({'uri' => '/admin/', 'method' => 'GET' })

      if( res.headers.include? 'Location' )
        target = URI(res.headers['Location'])
        print_status("Found console at #{target.path}")
      else
        print_error "redirect to websphere console login not found"
        return
      end

      print_status("Sending follow up request to #{target.path} to get login console")
      res = send_request_cgi({'uri' => "#{target.path}/", 'method' => 'GET' })

      if( res.body =~ /WebSphere Application Server Administrative Login/i )
        print_good("#{rhost} - IBM WebSphere Found.")
      else
        return
      end

      if( datastore['USER'] == "" )
        user = Rex::Text.rand_text_alpha(10)
      else
        user = datastore['USER']
      end

      if( datastore['AttemptLogin'] == true )
        print_status("Attempting to log in as user #{user}")
#        binding.pry
        res = send_request_cgi({
          'method' => 'POST',
          'uri' => '/ibm/console/secure/login.do',
          'data' => "username=#{user}&password=password&submit=Log+in"
         })
        p res.code
        if( res.body =~ /Administrative\ Console/i )
          print_good("#{rhost} - Websphere Login Success!" )
        else
          print_error"#{rhost} - Login failure"
        end
      end



      # Once we're here, fill in the admin field
      # POST to /ibm/console/login.do with username = USER
    rescue ::Timeout::Error, ::Errno::EPIPE
    end
  end


end
