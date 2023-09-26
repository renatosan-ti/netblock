require 'ipaddr'
require 'socket'
#require 'json'
#require_relative 'which'
require_relative 'validate'
require_relative 'asn'

class Whois	
	@whoisHost = "whois.pwhois.org"
	@whoisPort = 43
	@asn, @provider, @netblock, @output = nil
	
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
	end

	def self.pwhois(msg)	
		begin
		s = TCPSocket.new(@whoisHost, @whoisPort)

		s.write msg + "\n"		
		res = s.read		
		s.close
		rescue StandardError => e
			Print.err e.message
		else
			return res
		end
	end

	def self.command(*args)
		begin
			arg = args.join						
			@output = pwhois(arg)			
		rescue RuntimeError => e
			Print.err e.message
			exit!
		else
			return @output
		end	
	end
	
	# From https://rick-moore.medium.com/formatting-number-strings-in-ruby-4da35d5282e3
	def self.format_number(number)	
		whole, decimal = number.to_s.split(".")
		num_groups = whole.chars.to_a.reverse.each_slice(3)
		whole_with_commas = num_groups.map(&:join).join(',').reverse
		[whole_with_commas, decimal].compact.join(".")
	end

	def ip_to_asn(ipaddr)		
		# Input: IP address
		# Output: ASN
		begin						
			@output = JSON.parse(Whois.command("type=jsonp #{ipaddr}"))
			@asn = @output['Origin-AS']
			return @asn
		end
	end	
	
	def search_by_asn(asnCode)		
		validate = Validate.new
		result = Asn.new
		asn = Asn.format_asn(asnCode) # Essa linha retorna uma string
		p asn
		p result
		if Asn.check_asn_routes(asn)
			output = Asn.asn_to_provider_and_location(asn)
			@provider = output.first
			netblock = result.get_netblock(asn)
		
			Print.output_info(@asn, @provider, @location, netblock, @totalIPs, @ipBlock)
		end
	end

	def search_by_provider_name(provider)
		validate = Validate.new		
		output = get_provider_list(provider) #validate.provider(provider)

		asn = []

		output.each { |line| asn << asn_to_provider_and_location(line) }

		if output.count.eql?(1)						
			netblock = get_netblock(asn.first)
			Print.output_info(asn.first, provider.first, location.first, netblock, @totalIPs)			
		else			
			Print.providers_found(provider, asn)
		end		
	end
	
	def search_by_ipv4(ipaddr)		
		validate = Validate.new
		result = Asn.new
		@asn = ip_to_asn(ipaddr)
		@provider = @output['AS-Org-Name']
		@location = @output['City'] + "-" + @output['Region'] + " (" + @output['Country'] + ")"
		netblock = result.get_netblock(@asn, ipaddr)
		
		p @output
		Print.output_info(@asn, @provider, @location, netblock, result.totalIPs, result.ipBlock)		                   
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
