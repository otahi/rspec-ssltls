require 'rspec_ssltls'
require 'uri'

RSpec::Matchers.define :support_protocol do |protocol|
  match do |dest|
    fail 'No Argument Error.' unless protocol
    @protocol = Set.new + [protocol].flatten

    invalid_protocol = RspecSsltls::Util.invalid_ssl_tls_protocol(@protocol)
    fail "Invalid protocol.#{invalid_protocol.to_a}" if invalid_protocol

    @supported_protocol   = Set.new
    @not_supported_protocol = Set.new
    uri = URI.parse('https://' + dest)

    @protocol.each do |pr|
      socket = TCPSocket.open(uri.host, uri.port)
      ssl_context = OpenSSL::SSL::SSLContext.new(pr)
      ssl_context.ciphers = ['ALL']
      ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
      ssl_socket.sync_close = true
      begin
        ssl_socket.connect
        @supported_protocol.add(pr) if ssl_socket.ssl_version
        ssl_socket.close
      rescue
        @not_supported_protocol.add(pr)
      ensure
        ssl_socket && ssl_socket.close
      end
    end
    (@protocol - @supported_protocol).size == 0
  end

  description do
    "support protocol #{@protocol.to_a.join(', ')}"
  end

  failure_message do
    s  = "expected to support protocol #{@protocol.to_a}, but did not."
    s += "\n  suppported protocol:     #{@supported_protocol.to_a}."
    s +  "\n  not suppported protocol: #{@not_supported_protocol.to_a}."
  end

  failure_message_when_negated do
    s =  "expected not to support protocol #{@protocol.to_a}, but did."
    s += "\n  suppported protocol:     #{@supported_protocol.to_a}."
    s +  "\n  not suppported protocol: #{@not_supported_protocol.to_a}."
  end
end
