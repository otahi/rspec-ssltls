require 'rspec_ssltls'
require 'uri'

RSpec::Matchers.define :have_certificate do
  match do |dest|
    @chain_string = ''
    @result_string = ''
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

  def valid_cert?
    @result_cert = {}
    @result_cert.merge!(subject: valid_subject?)
    @result_cert.values.all? { |r| r == true }
  end

  def valid_subject?
    return true unless @subject
    invalid = false
    @subject.each_pair do |k, v|
      value = cert_value(k)
      next if value == v
      @result_string += "  expected: #{k}=#{v}\n  actual:   #{k}=#{value}\n"
      invalid = true
    end
    invalid ? false : true
  end

  def cert_value(key)
    values = @peer_cert.subject.to_a.select do |k, _, _|
      k.to_s == key.to_s
    end
    values.first ? values.first[1] : ''
  end

  chain :subject do |subject|
    fail 'Argument Error. Needs hash arguments' unless
      subject.respond_to?(:each_pair)

    @subject = subject
    @subject.each_pair do |k, v|
      RspecSsltls::Util.add_string(@chain_string, "#{k}=#{v}")
    end
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
