class Provider
  def get_provider_list(provider)
		orgName = []
		
		begin
			output = JSON.parse(Whois.command("type=jsonp routeview org-name=#{provider}"), {symbolize_names: true})[:Records]
			unless output.nil?
				output.each_with_index do |line, i|          
					orgName << output[i][:"Org-Name"]
				end
			else
				raise "#{provider}".light_red + " isn't a valid provider"
			end      
			
			@provider = orgName
		rescue RuntimeError => e
			Print.err e.message
			exit!		
		else      
			return @provider
		end	
	end

  def provider_to_asn(provider)	
		orgName = []
		asn = []
		location = []
		
		begin
			#raise "No internet connection" if Whois.has_internet? == false
			output = JSON.parse(Whois.command("type=jsonp routeview org-name=#{provider}"), {symbolize_names: true})[:Records]
			unless output.nil?
				output.each_with_index do |line, i|          
					orgName << output[i][:"Org-Name"]					
				end
			else
				raise "#{provider}".light_red + " isn't a valid provider"
			end      

			@provider = orgName			
		rescue RuntimeError => e
			Print.err e.message
			exit!		
		else      
			return @provider, @asn, @location
		end	
	end

end