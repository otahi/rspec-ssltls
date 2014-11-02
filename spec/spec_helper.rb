require 'coveralls'
Coveralls.wear!

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '.bundle/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rspec_ssltls'
require 'openssl'
require 'fileutils'

def stub_ssl_socket(params = nil)
  allow(TCPSocket).to receive(:open).and_return(nil)
  allow(OpenSSL::SSL::SSLSocket).to receive(:new) do
    ssl_socket = double('ssl_socket')
    allow(ssl_socket).to receive(:method_missing).and_return(nil)
    params.each_pair do |k, v|
      allow(ssl_socket).to receive(k).and_return(v)
    end if params
    ssl_socket
  end
end

def prepare_ca_certs
  example_ca_key = OpenSSL::PKey::RSA.new 2048 # the CA's public/private key
  example_ca_cert = OpenSSL::X509::Certificate.new
  example_ca_cert.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
  example_ca_cert.serial = 1
  example_ca_cert.subject =
    OpenSSL::X509::Name.new([%w(C US),
                             %w(O Example\ Org.),
                             %w(OU Example\ Org.\ Div.),
                             %w(CN ca.example.org)
                            ])
  example_ca_cert.issuer = example_ca_cert.subject # self-signed
  example_ca_cert.public_key = example_ca_key.public_key
  example_ca_cert.not_before =
    Time.utc(0, 0, 0, 1, 10, 2014, nil, nil, nil, nil)
  example_ca_cert.not_after  =
    Time.utc(0, 0, 0, 1, 10, 2022, nil, nil, nil, nil)
  example_ca_cert.sign(example_ca_key, OpenSSL::Digest::SHA256.new)

  example_key = OpenSSL::PKey::RSA.new 2048 # the CA's public/private key
  example_cert = OpenSSL::X509::Certificate.new
  example_cert.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
  example_cert.serial = 1
  example_cert.subject =
    OpenSSL::X509::Name.new([%w(C JP),
                             %w(ST Tokyo),
                             %w(O Example\ Co.,\ Ltd.),
                             %w(OU Example\ Div.),
                             %w(CN *.example.com)
                            ])
  example_cert.issuer = example_ca_cert.subject
  example_cert.public_key = example_key.public_key
  example_cert.not_before =
    Time.utc(5, 0, 19, 12, 9, 2014, nil, nil, nil, nil)
  example_cert.not_after  =
    Time.utc(0, 0, 0, 1, 10, 2015, nil, nil, nil, nil)
  example_cert.sign(example_ca_key, OpenSSL::Digest::SHA256.new)

  FileUtils.mkdir_p('tmp')
  File.open('tmp/ca_cert.key', 'wb') { |f| f.print example_ca_key.to_pem }
  File.open('tmp/ca_cert.cer', 'wb') { |f| f.print example_ca_cert.to_pem }
  File.open('tmp/cert.key', 'wb') { |f| f.print example_key.to_pem }
  File.open('tmp/cert.cer', 'wb') { |f| f.print example_cert.to_pem }

  [example_ca_cert, example_cert]
end

def cleanup_ca_certs
  %w(tmp/ca_cert.key tmp/ca_cert.cer tmp/cert.key tmp/cert.cer)
    .each { |f|  File.delete(f) if File.exist?(f) }
end
