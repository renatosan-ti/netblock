require 'colorize'

class Print
  @appName = "netblock"
  @appVersion = "1.0.3"	

  def self.err(text); print " ERROR ".bold.on_light_red + " #{text}\n" end
  def self.msg(text); print " INFO ".bold.on_blue + " #{text}\n" end

  def self.providers_found(provider, asn)
    begin
      unless provider.count.zero?        
        print "%10s %s %s\n".bold % ["ASN", "│".blue, "Provider name".bold]
        provider.each_with_index do |name, index|         
          print "%10s %s %s\n" % [ "AS#{asn[index]}", "│".blue, name.light_cyan ]
        end
        msg "Found: #{Whois.format_number(provider.count).bold}"
      else
        raise "No provider found"
      end
    rescue RuntimeError => e
      err e.message
      exit!
    end
  end

  def self.install_whois
    msg "whois".light_blue + " client seems not to be installed"
    exit
  end

  def self.output_info(asn, provider, location, netblock, totalIPs, *ipBlock)
    print "%16s %s %s\n".bold % ["ASN", "│".blue, "AS#{asn.to_s}".light_cyan]
    print "%16s %s %s\n".bold % ["Provider", "│".blue, provider.strip.light_cyan]
    print "%16s %s %s\n".bold % ["Location", "│".blue, location.strip.light_cyan] 
    print "%16s %s %s\n".bold % ["IP block", "│".blue, ipBlock.join.gsub(/\.\./, '-').light_cyan] if ipBlock
    print "%16s %s %s\n".bold % ["Netblock", "│".blue, netblock.join(" ").light_cyan]
    print "%16s %s %s\n".bold % ["Total IP(s)", "│".blue, Whois.format_number(totalIPs).light_cyan]
  end  

  def self.show_help()    
    print "#{@appName.bold} v#{@appVersion}\n\nUsage: #{@appName.bold} [ASN] | [IP Address] | [Provider name]\n"    
    exit
  end 
end