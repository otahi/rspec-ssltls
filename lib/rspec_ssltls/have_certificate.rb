require 'rspec_ssltls'
require 'uri'

RSpec::Matchers.define :have_certificate do
  match do |dest|
    @chain_string = ''
    uri = URI.parse('https://' + dest)
    socket = TCPSocket.open(uri.host, uri.port)
    ssl_context = OpenSSL::SSL::SSLContext.new
    ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
    ssl_socket.sync_close = true
    ssl_socket.connect
    @peer_cert = ssl_socket.peer_cert
    ssl_socket.close

    @peer_cert ? true : false
  end

  description do
    "have a certificate#{@chain_string}"
  end

  failure_message do
    "expected to have a certificate#{@chain_string}, but did not."
  end

  failure_message_when_negated do
    "expected not to have a certificate#{@chain_string}, but did."
  end

end
