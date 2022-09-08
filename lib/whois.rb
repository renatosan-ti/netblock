require 'ipaddr'
#require 'json'
#require_relative 'which'
require_relative 'validate'

class Whois	
	@whoisHost = "whois.pwhois.org"
	@asn, @provider, @netblock = nil
	
	# From https://stackoverflow.com/a/22837368/4603968
	def self.has_internet?		
		require "resolv"
		dns_resolver = Resolv::DNS.new()
		begin
			dns_resolver.getaddress(@whoisHost)			
			return true
		rescue Resolv::ResolvError => e					
			return false			
		end
	end

	def check_whois_command
		begin
			Print.install_whois unless which('whois')
		rescue RuntimeError => e			
			Print.err e.message
			exit!
		end

		#if Whois.has_internet? == false
		#	Print.err "No internet connection"
		#	exit!
		#else
		#	Print.install_whois unless which('whois')
		#end
	end

	def self.command(*args)
		begin
			arg = args.join						
			output = %x{whois -h #{@whoisHost} #{arg}}			
		rescue RuntimeError => e
			Print.err e.message
			exit!
		else
			return output
		end	
	end
	
	# From https://rick-moore.medium.com/formatting-number-strings-in-ruby-4da35d5282e3
	def self.format_number(number)	
		whole, decimal = number.to_s.split(".")
		num_groups = whole.chars.to_a.reverse.each_slice(3)
		whole_with_commas = num_groups.map(&:join).join(',').reverse
		[whole_with_commas, decimal].compact.join(".")
	end

	def format_asn(asn)
		if asn.to_s.start_with?("AS")
			return asn[2..-1]
		else
			return asn
		end
	end

	def check_asn_routes(asn)
		asn = format_asn(asn)
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
	
	def get_provider_name(asn)
		validate = Validate.new
		asn = format_asn(asn)
    
    if validate.asn(asn)			
    	output = JSON.parse(Whois.command("type=jsonp registry source-as=#{asn}")).fetch('records')
			output.select do |line| 
				@provider = line['Org-Name']
				#@location = line['City']
			end
    	return @provider #, @location
		end
	end

	def get_netblock(asn, *args)
		validate = Validate.new
		asn = format_asn(asn)

    netblock = []
		@ipBlock = []
    @totalIPs = 0		
		
    if validate.asn(asn)    	
			JSON.parse(Whois.command("type=jsonp netblock source-as=#{asn}"), {symbolize_names: true})[:ASes].each do |ases|
				ases[:Nets].each_entry do |ip|
					fromIP = ip[:"Net-Range"].split("-").first.strip
					toIP = ip[:"Net-Range"].split("-").last.strip
					ip_range = IPAddr.new(fromIP)..IPAddr.new(toIP)
					@ipBlock << ip_range if ip_range.include?(@ipv4)

					netblock << "#{fromIP}-#{toIP}"
					@totalIPs += ip_range.count					
				end
			end
			return netblock			
		end
	end

	def get_ipaddr_info(ipaddr)		
		begin						
			output = JSON.parse(Whois.command("type=jsonp #{ipaddr}"))
			@asn = output['Origin-AS']
			@provider = output['AS-Org-Name']
			
			return @asn, @provider
		end
	end	

	def search_by_asn(asn)		
		validate = Validate.new
		asn = format_asn(asn)

		@asn = validate.asn(asn)
		check_asn_routes(@asn)
		@provider = get_provider_name(@asn)
		netblock = get_netblock(@asn)
		
		Print.output_info(@asn, @provider, netblock, @totalIPs)
	end

	def search_by_provider_name(provider)
		validate = Validate.new		
		@provider = validate.provider(provider)

		provider = @provider.first
		asn = @provider.last
		#city = @provider[2]

		if asn.count.eql?(1)						
			netblock = get_netblock(asn.first)
			Print.output_info(asn.first, provider.first, netblock, @totalIPs)			
		else			
			Print.providers_found(provider, asn)
		end		
	end
	
	def search_by_ipv4(ipaddr)		
		validate = Validate.new
		@ipv4 = validate.ipv4(ipaddr)
		asn = get_ipaddr_info(@ipv4)
		
		@asn = asn.first
		@provider = asn.last
		netblock = get_netblock(@asn)
		Print.output_info(@asn, @provider, netblock, @totalIPs, @ipBlock)
	end	

	def search_by_ipv6(ipaddr)		
		begin
			raise "Not implemented" if IPAddr.new(ipaddr).ipv6?	
		rescue IPAddr::InvalidAddressError => e
			Print.err e.message
			exit!
		end
	end
end