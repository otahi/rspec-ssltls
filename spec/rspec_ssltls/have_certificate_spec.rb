require 'spec_helper'
require 'rspec_ssltls'

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

# See http://www.ietf.org/rfc/rfc5280.txt 4.1.2.4
example_cert_name =
  OpenSSL::X509::Name.new([%w(C JP),
                           %w(ST Tokyo),
                           %w(O Example\ Co.,\ Ltd.),
                           %w(OU Example\ Div.),
                           %w(CN *.example.com)
                          ])
example_cert = OpenSSL::X509::Certificate.new
example_cert.subject = example_cert_name

example_ca_cert_name =
  OpenSSL::X509::Name.new([%w(C US),
                           %w(O Example\ Org.),
                           %w(OU Example\ Org.\ Div.),
                           %w(CN *.example.org)
                          ])
example_ca_cert = OpenSSL::X509::Certificate.new
example_ca_cert.subject = example_ca_cert_name

describe 'rspec-ssltls matchers' do
  describe '#have_certificate' do
    it 'can evalutate having certificate' do
      stub_ssl_socket(peer_cert: nil)
      expect('www.example.com:443').not_to have_certificate
      stub_ssl_socket(peer_cert: example_cert)
      expect('www.example.com:443').to have_certificate
    end
    it 'can evalutate having certificate subject' do
      stub_ssl_socket(peer_cert: example_cert)
      expect('www.example.com:443')
        .to have_certificate.subject(CN: '*.example.com')
      expect('www.example.com:443')
        .to have_certificate.subject(CN: '*.example.com',
                                     C: 'JP',
                                     ST: 'Tokyo',
                                     O: 'Example Co., Ltd.',
                                     OU: 'Example Div.',
                                     CN: '*.example.com'
                                     )
      expect('www.example.com:443')
        .not_to have_certificate.subject(CN: 'www.example.com')
    end
  end
end
