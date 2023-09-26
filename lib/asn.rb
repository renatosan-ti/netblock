class Asn

  @ipBlock = []
  @totalIPs = 0

  attr_reader :totalIPs, :ipBlock
  
  def self.format_asn(asn)
    if asn.to_s.start_with?("AS")
      return asn[2..-1]
    else
      return asn
    end
  end

  def self.check_asn_routes(asn)		
    begin						
      output = Whois.command("type=jsonp routeview source-as=#{asn}")
      raise 'No prefixes found in routeview' unless JSON.parse(output).key?("routes")
    rescue StandardError => e
      Print.err e.message
      exit!		
    else
      return true
    end	
  end

  def self.asn_to_provider_and_location(asn)
    validate = Validate.new
    
    if validate.asn(asn)			
      output = JSON.parse(Whois.command("type=jsonp registry source-as=#{asn}")).fetch('records')
      output.select do |line| 
        @provider = line['Org-Name']
        @location = "#{line[:City]}-#{line[:Country]}"
      end
      return @provider, @location
    end
  end

  def get_netblock(asn, *ipv4)
    # Input: ASN
    # Output: netblock, IP block and block with IP inside

    validate = Validate.new
    #asn = format_asn(asn)
    
    netblock = []
    @ipBlock = []
    @totalIPs = 0		
    
    if validate.asn(asn)    	
      JSON.parse(Whois.command("type=jsonp netblock source-as=#{asn}"), {symbolize_names: true})[:ASes].each do |ases|
        ases[:Nets].each_entry do |ip|
          fromIP = ip[:"Net-Range"].split("-").first.strip
          toIP = ip[:"Net-Range"].split("-").last.strip

          ip_range = IPAddr.new(fromIP)..IPAddr.new(toIP)

          @ipBlock << ip_range if ip_range.include?(ipv4) if ipv4
          
          netblock << "#{fromIP}-#{toIP}"
          @totalIPs += ip_range.count		          
        end
      end
      return netblock
    end
  end
end