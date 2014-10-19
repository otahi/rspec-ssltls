require 'spec_helper'
require 'rspec_ssltls'

describe 'rspec-ssltls matchers' do
  describe '#support_cipher' do
    it 'can evalutate support cipher' do
      stub_ssl_socket(cipher: ['DES-CBC3-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to support_cipher('DES-CBC3-SHA')

      stub_ssl_socket(cipher: ['AES256-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to support_cipher(['AES256-SHA', 'DES-CBC3-SHA'])

      stub_ssl_socket(cipher: nil)
      expect('www.example.com:443')
        .not_to support_cipher('AES256-SHA')
    end
    it 'can evalutate support cipher specified with protocol' do
      stub_ssl_socket(cipher: ['AES256-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to support_cipher('AES256-SHA').protocol('TLSv1')
    end

    # show default description
    it do
      stub_ssl_socket(cipher: ['DES-CBC3-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to support_cipher('DES-CBC3-SHA')
    end
  end
end
