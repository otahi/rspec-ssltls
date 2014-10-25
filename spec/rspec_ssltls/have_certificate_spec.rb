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
example_ca_cert_name =
  OpenSSL::X509::Name.new([%w(C US),
                           %w(O Example\ Org.),
                           %w(OU Example\ Org.\ Div.),
                           %w(CN ca.example.org)
                          ])
example_ca_cert = OpenSSL::X509::Certificate.new
example_ca_cert.subject = example_ca_cert_name
example_ca_cert.not_before = Time.utc(0, 0, 0, 1, 10, 2014, nil, nil, nil, nil)
example_ca_cert.not_after  = Time.utc(0, 0, 0, 1, 10, 2022, nil, nil, nil, nil)

example_cert_name =
  OpenSSL::X509::Name.new([%w(C JP),
                           %w(ST Tokyo),
                           %w(O Example\ Co.,\ Ltd.),
                           %w(OU Example\ Div.),
                           %w(CN *.example.com)
                          ])
example_cert = OpenSSL::X509::Certificate.new
example_cert.subject = example_cert_name
example_cert.issuer = example_ca_cert_name
example_cert.not_before = Time.utc(5, 0, 19, 12, 9, 2014, nil, nil, nil, nil)
example_cert.not_after  = Time.utc(0, 0, 0, 1, 10, 2015, nil, nil, nil, nil)

describe 'rspec-ssltls matchers' do
  describe '#have_certificate' do
    it 'can evalutate having certificate' do
      stub_ssl_socket(peer_cert_chain: [nil])
      expect('www.example.com:443').not_to have_certificate
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
    end
    it 'can evalutate having certificate subject' do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443')
        .to have_certificate.subject(CN: '*.example.com')
      expect('www.example.com:443')
        .to have_certificate.subject(CN: '*.example.com',
                                     C:  'JP',
                                     ST: 'Tokyo',
                                     O:  'Example Co., Ltd.',
                                     OU: 'Example Div.'
                                     )
      expect('www.example.com:443')
        .not_to have_certificate.subject(CN: 'www.example.com')
    end

    # show default description
    it do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443')
        .to have_certificate.subject(CN: '*.example.com',
                                     C:  'JP',
                                     ST: 'Tokyo',
                                     O:  'Example Co., Ltd.',
                                     OU: 'Example Div.'
                                     )
    end

    it 'can evalutate having certificate issuer' do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443')
        .to have_certificate.issuer(CN: 'ca.example.org')
      expect('www.example.com:443')
        .to have_certificate.issuer(CN: 'ca.example.org',
                                    C:  'US',
                                    O:  'Example Org.',
                                    OU: 'Example Org. Div.'
                                    )

      expect('www.example.com:443')
        .not_to have_certificate.issuer(CN: 'www.example.org')
    end

    # show default description
    it do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443')
        .to have_certificate.issuer(CN: 'ca.example.org',
                                    C:  'US',
                                    O:  'Example Org.',
                                    OU: 'Example Org. Div.'
                                    )
    end

    it 'can evalutate having certificate in chain' do
      stub_ssl_socket(peer_cert_chain: [nil])
      expect('www.example.com:443').not_to have_certificate.chain(0)
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate.chain(0)
    end
    it 'can evalutate having certificate subject in chain' do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443')
        .to have_certificate.chain(0).subject(CN: '*.example.com')
      expect('www.example.com:443')
        .to have_certificate.chain(0).subject(CN: '*.example.com',
                                              C:  'JP',
                                              ST: 'Tokyo',
                                              O:  'Example Co., Ltd.',
                                              OU: 'Example Div.'
                                              )
      expect('www.example.com:443')
        .not_to have_certificate.chain(0).subject(CN: 'www.example.com')
    end

    # show default description
    it do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443')
        .to have_certificate.chain(0).subject(CN: '*.example.com',
                                              C:  'JP',
                                              ST: 'Tokyo',
                                              O:  'Example Co., Ltd.',
                                              OU: 'Example Div.'
                                              )
    end

    it 'can evalutate having certificate subject valid_at' do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
        .subject(CN: '*.example.com')
        .valid_at('2014/10/01 09:34 JST')

      expect('www.example.com:443').to have_certificate
        .subject(CN: '*.example.com',
                 C:  'JP',
                 ST: 'Tokyo',
                 O:  'Example Co., Ltd.',
                 OU: 'Example Div.'
                 )
        .valid_at('2014/10/01 09:34 JST')
      expect('www.example.com:443').not_to have_certificate
        .subject(CN: '*.example.com')
        .valid_at('2014/09/01 12:34 JST')
    end

    # show default description
    it do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
        .subject(CN: '*.example.com')
        .valid_at('2014/10/01 09:34 JST')
    end

    it 'can evalutate having certificate subject valid_in' do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
        .subject(CN: '*.example.com')
        .valid_in('2014/09/12 19:00:05 UTC', '2015/10/01 00:00:00 UTC')

      expect('www.example.com:443').to have_certificate
        .subject(CN: '*.example.com',
                 C:  'JP',
                 ST: 'Tokyo',
                 O:  'Example Co., Ltd.',
                 OU: 'Example Div.'
                 )
        .valid_in('2014/09/12 19:00:05 UTC', '2015/10/01 00:00:00 UTC')
      expect('www.example.com:443').not_to have_certificate
        .subject(CN: '*.example.com')
        .valid_in('2014/09/12 19:00:05 UTC', '2025/10/01 00:00:00 UTC')
      expect('www.example.com:443').not_to have_certificate
        .subject(CN: '*.example.com')
        .valid_in(Time.parse('2014/09/12 19:00:05 UTC'),
                  Time.parse('2025/10/01 00:00:00 UTC'))
    end

    # show default description
    it do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
        .subject(CN: '*.example.com')
        .valid_in('2014/09/12 19:00:05 UTC', '2015/10/01 00:00:00 UTC')
    end
  end
end
