require 'rspec_ssltls'
require 'uri'

# See Ciphers
# https://www.openssl.org/docs/apps/ciphers.html

RSpec::Matchers.define :choose_cipher do |cipher|
  match do |dest|
    fail 'No Argument Error.' unless cipher
    @protocol ||= 'SSLv23'
    @ciphers ||= ['ALL']
    @expected_cipher = cipher

    uri = URI.parse('https://' + dest)

    socket = RspecSsltls::Util.open_socket(uri, proxy: @proxy)
    ssl_context = OpenSSL::SSL::SSLContext.new(@protocol)
    ssl_context.ciphers = @ciphers
    ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
    ssl_socket.sync_close = true
    result = false
    begin
      ssl_socket.connect
      @actual_cipher = ssl_socket.cipher ? ssl_socket.cipher.first : nil
      result = (cipher == @actual_cipher)
      ssl_socket.close
    ensure
      ssl_socket && ssl_socket.close
    end
    result
  end

  chain :from do |ciphers|
    @ciphers = [ciphers].flatten
    @chain_string =
      RspecSsltls::Util.add_string(@chain_string, "from #{@ciphers}")
  end
  chain :protocol do |protocol|
    invalid_protocol = RspecSsltls::Util.invalid_ssl_tls_protocol(protocol)
    fail "Invalid protocol.#{invalid_protocol.to_a}" if invalid_protocol
    @protocol = [protocol].flatten.first
    @chain_string =
      RspecSsltls::Util.add_string(@chain_string, "on #{@protocol}")
  end

  chain :via_proxy do |proxy|
    @proxy = proxy
  end

  description do
    "choose cipher #{@expected_cipher}#{@chain_string}"
  end

  failure_message do
    s  = "expected to choose cipher #{@expected_cipher}"
    s += "#{@chain_string}, but did not."
    s += "\n  expected: #{@expected_cipher}."
    s +  "\n  actual:   #{@actual_cipher ? @actual_cipher : 'nil'}."
  end

  failure_message_when_negated do
    s =  "expected not to choose cipher #{@expected_cipher}"
    s += "#{@chain_string}, but did."
    s += "\n  expected not: #{@expected_cipher}."
    s +  "\n  actual:       #{@actual_cipher ? @actual_cipher : 'nil'}."
  end
end
