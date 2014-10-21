require 'rspec_ssltls'
require 'uri'

RSpec::Matchers.define :have_certificate do
  match do |dest|
    @chain_string ||= ''
    @result_string ||= ''
    uri = URI.parse('https://' + dest)
    socket = TCPSocket.open(uri.host, uri.port)
    ssl_context = OpenSSL::SSL::SSLContext.new
    ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
    ssl_socket.sync_close = true
    ssl_socket.connect
    @peer_cert = ssl_socket.peer_cert
    ssl_socket.close
    @peer_cert ? valid_cert? : false
  end

  chain :subject do |id|
    fail 'Argument Error. Needs hash arguments' unless
      id.respond_to?(:each_pair)

    @subject = id
    kv = @subject.each_pair.map { |k, v| "#{k}=\"#{v}\"" }.join(', ')
    @chain_string =
      RspecSsltls::Util.add_string(@chain_string, "subject #{kv}")
  end

  chain :issuer do |id|
    fail 'Argument Error. Needs hash arguments' unless
      id.respond_to?(:each_pair)

    @issuer = id
    kv = @issuer.each_pair.map { |k, v| "#{k}=\"#{v}\"" }.join(', ')
    @chain_string =
      RspecSsltls::Util.add_string(@chain_string, "issuer #{kv}")
  end

  def valid_cert?
    @result_cert = {}
    @result_cert.merge!(subject: valid_identifier?(:subject, @subject))
    @result_cert.merge!(issuer:  valid_identifier?(:issuer, @issuer))
    @result_cert.values.all? { |r| r == true }
  end

  def valid_identifier?(kind, id)
    return true unless id
    invalid = false
    id.each_pair do |k, v|
      value = cert_value(kind, k)
      next if value == v
      @result_string += "  expected: #{k}=\"#{v}\"\n"
      @result_string += "  actual:   #{k}=\"#{value}\"\n"
      invalid = true
    end
    invalid ? false : true
  end

  def cert_value(kind, key)
    values = @peer_cert.send(kind).to_a.select do |k, _, _|
      k.to_s == key.to_s
    end
    values.first ? values.first[1] : ''
  end

  description do
    "have a certificate#{@chain_string}"
  end

  failure_message do
    s = "expected to have a certificate#{@chain_string}, but did not."
    s + "\n#{@result_string}"
  end

  failure_message_when_negated do
    s = "expected not to have a certificate#{@chain_string}, but did."
    s + "\n#{@result_string}"
  end
end
