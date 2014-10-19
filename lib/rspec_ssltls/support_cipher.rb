require 'rspec_ssltls'
require 'uri'

# See Chiphers
# https://www.openssl.org/docs/apps/ciphers.html

RSpec::Matchers.define :support_cipher do |cipher|
  match do |dest|
    fail 'No Argument Error.' unless cipher
    @protocol ||= 'SSLv23'
    @cipher = Set.new + [cipher].flatten

    @supported_cipher   = Set.new
    @not_supported_cipher = Set.new
    uri = URI.parse('https://' + dest)

    @cipher.each do |ci|
      socket = TCPSocket.open(uri.host, uri.port)
      ssl_context = OpenSSL::SSL::SSLContext.new(@protocol)
      ssl_context.ciphers = [ci]
      ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
      ssl_socket.sync_close = true
      begin
        ssl_socket.connect
        @supported_cipher.add(ci) if ssl_socket.cipher
        ssl_socket.close
      rescue
        @not_supported_cipher.add(ci)
      ensure
        ssl_socket && ssl_socket.close
      end
    end
    (@cipher - @supported_cipher).size == 0
  end

  chain :protocol do |protocol|
    invalid_protocol = RspecSsltls::Util.invalid_ssl_tls_protocol(protocol)
    fail "Invalid protocol.#{invalid_protocol.to_a}" if invalid_protocol
    @protocol = [protocol].flatten.first
    @chain_string =
      RspecSsltls::Util.add_string(@chain_string, "on #{@protocol}")
  end

  description do
    "support cipher #{@cipher.to_a}"
  end

  failure_message do
    s  = "expected to support cipher #{@cipher.to_a}"
    s += "#{@chain_string}, but did not."
    s += "\n  suppported cipher:     #{@supported_cipher.to_a}."
    s +  "\n  not suppported cipher: #{@not_supported_cipher.to_a}."
  end

  failure_message_when_negated do
    s =  "expected not to support cipher #{@cipher.to_a}"
    s += "#{@chain_string}, but did."
    s += "\n  suppported cipher:     #{@supported_cipher.to_a}."
    s +  "\n  not suppported cipher: #{@not_supported_cipher.to_a}."
  end
end
