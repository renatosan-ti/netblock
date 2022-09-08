#require 'ipaddr'
require 'json'

require_relative 'whois'
require_relative 'print'

class Validate
  def ipv4(ipaddr)    
    begin      
      raise "IPv4 only" if IPAddr.new(ipaddr).ipv6?
      raise "Link local" if IPAddr.new(ipaddr).link_local?
      raise "Loopback address" if IPAddr.new(ipaddr).loopback?      
      raise "Private IP address" if IPAddr.new(ipaddr).private?
      raise "No internet connection" if Whois.has_internet? == false	

      output = JSON.parse(Whois.command("type=json #{ipaddr}")) 
      raise "#{ipaddr}".light_red + " isn't a valid IP address" if output.has_key?("error")      
    rescue StandardError => e
      Print.err e.message
    	exit!	
    else
      return ipaddr	
    end
  end

  def asn(asn)   
    begin						
      raise "No internet connection" if Whois.has_internet? == false
      output = Whois.command("type=jsonp registry source-as=#{asn}")   
      raise "#{asn}".light_red + " isn't a valid ASN code" if output.empty? || JSON.parse(output).has_key?("error")
    rescue StandardError => e
      Print.err e.message
    	exit!		
    else
      return asn
    end
  end

  def provider(provider)
    orgName = []
    asn = []

    begin
      raise "No internet connection" if Whois.has_internet? == false
      output = JSON.parse(Whois.command("type=jsonp routeview org-name=#{provider}"), {symbolize_names: true})[:Records]
      unless output.nil?
        output.each_with_index do |line, i|
          orgName << output[i][:"Org-Name"]
          asn << output[i][:"Origin-AS"]
        end
      else
        raise "#{provider}".light_red + " isn't a valid provider"
      end

      @provider = orgName
      @asn = asn
    rescue RuntimeError => e
      Print.err e.message
    	exit!		
    else      
      return @provider, @asn
    end
  end
end