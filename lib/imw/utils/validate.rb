

# Return true if <tt>email</tt> is a valid email address
def is_email?(email)
  raise ArgumentError, "'email' must be a string" if email.class != String
  return false if email.empty?

  parts = email.split('@')
  return false if parts.size != 2
  
  local = parts.first
  return false if not local =~ /[a-zA-Z0-9_~=+-.]*/ # allowed characters
  return false if local[0,1] == '.' # starts with .
  return false if local[-1,1] == '.' # end with .
  return false if local.include?('..') # can't repeat .

  domain = parts.last
  return false if not is_domain?(domain)

  return true
end

# Return true if <tt>domain</tt> is a valid domain name
def is_domain?(domain)
  raise ArgumentError, "'domain' must be a string" if domain.class != String
  return false if domain.empty?

  return false if domain.size > 255 # max number of characters in a domain
  return false if not domain =~ /^[a-zA-Z0-9.\-]+$/ # allowed characters
  parts = domain.split('.')
  return false if parts.size > 127 # max number of subdomains
  parts.all? {|part| return false if part.size > 63} # max number of characters in a subdomain
  
  return true
end
  

# puts "#{File.basename(__FILE__)}: As you shape your body to the confines of your container you feel a tremendous sense of validation." # at bottom
