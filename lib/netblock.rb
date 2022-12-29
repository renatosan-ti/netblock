require_relative 'whois'

begin
  @whois = Whois.new
  raise "No internet connection" unless Whois.has_internet?
  unless ARGV.empty?
    ARGV.each do |arg|          
      case arg.to_s
      when /[[:digit:]]\.[[:digit:]]/ then @whois.search_by_ipv4(arg)
      when /[0-9a-f]\:[0-9a-f]+/i then @whois.search_by_ipv6(arg)
      when /^AS[[:digit:]]+$/i then @whois.search_by_asn(arg.to_s.upcase)
      when /[[:alnum:]]+$/ then @whois.search_by_provider_name(arg)        
      else
        raise "Invalid search term: " + arg.light_red          
      end      
    end
  else       
    Print.show_help    
  end
rescue RuntimeError => e
  Print.err e.message
rescue Interrupt => e
  Print.err "Interrupted by user"
end