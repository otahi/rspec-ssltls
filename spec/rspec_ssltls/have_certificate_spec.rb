require 'spec_helper'
require 'rspec_ssltls'

example_ca_cert, example_cert = prepare_ca_certs

describe 'rspec-ssltls matchers' do
  describe '#have_certificate' do
    before :each do
      allow(example_ca_cert).to receive(:signature_algorithm)
        .and_return('sha512WithRSAEncryption')
      allow(example_cert).to receive(:signature_algorithm)
        .and_return('sha1WithRSAEncryption')
    end

    after :all do
      cleanup_ca_certs
    end

    ## Having certificate
    it 'can evalutate having certificate' do
      stub_ssl_socket(peer_cert_chain: [nil])
      expect('www.example.com:443').not_to have_certificate
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
    end

    ## Subject
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

    ## Issuer
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

    ## Chain
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

    ## Valid at
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

    ## Valid in
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

    ## Signature algolizm
    it 'can evalutate certificate signature algorithm' do
      stub_ssl_socket(peer_cert_chain: [example_cert, example_ca_cert])
      expect('www.example.com:443').to have_certificate
        .subject(CN: '*.example.com')
        .signature_algorithm('sha1WithRSAEncryption')
      expect('www.example.com:443').to have_certificate
        .chain(1).subject(CN: 'ca.example.org')
        .signature_algorithm('sha512WithRSAEncryption')
      expect('www.example.com:443').not_to have_certificate
        .subject(CN: '*.example.com')
        .signature_algorithm('sha512WithRSAEncryption')
    end

    # show default description
    it do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
        .subject(CN: '*.example.com')
        .signature_algorithm('sha1WithRSAEncryption')
    end

    ## Verified
    it 'can evalutate certificate verified' do
      stub_ssl_socket(peer_cert_chain: [example_cert, example_ca_cert])
      expect('www.example.com:443').to have_certificate
        .verified
      stub_ssl_socket(peer_cert_chain: nil)
      expect('www.example.com:443').not_to have_certificate
        .verified
    end

    # show default description
    it do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
        .verified
    end

    ## Verified with CA certficate
    it 'can evalutate certificate verified with CA certificate' do
      stub_ssl_socket(peer_cert_chain: [example_cert, example_ca_cert])
      expect('www.example.com:443').to have_certificate
        .verified_with('tmp/ca_cert.cer')
      stub_ssl_socket(peer_cert_chain: nil)
      expect('www.example.com:443').not_to have_certificate
        .verified_with('tmp/cert.cer')
    end

    # show default description
    it do
      stub_ssl_socket(peer_cert_chain: [example_cert])
      expect('www.example.com:443').to have_certificate
        .verified_with('tmp/ca_cert.cer')
    end
  end
end
