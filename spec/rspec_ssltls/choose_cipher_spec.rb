require 'spec_helper'
require 'rspec_ssltls'

describe 'rspec-ssltls matchers' do
  describe '#choose_cipher' do
    it 'can evalutate choose cipher' do
      stub_ssl_socket(cipher: ['DES-CBC3-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to choose_cipher('DES-CBC3-SHA')

      stub_ssl_socket(cipher: ['AES256-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to choose_cipher('AES256-SHA')

      stub_ssl_socket(cipher: ['AES256-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .not_to choose_cipher('DES-CBC3-SHA')
    end

    it 'can evalutate choose cipher from list' do
      stub_ssl_socket(cipher: ['DES-CBC3-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to choose_cipher('DES-CBC3-SHA').from(['ALL', '!EXP'])

      stub_ssl_socket(cipher: ['AES256-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .not_to choose_cipher('DES-CBC3-SHA').from('ALL')
    end

    it 'can evalutate choose cipher via proxy' do
      https_proxy = 'http://user:pass@proxy.example.com/'
      stub_ssl_socket(cipher: ['DES-CBC3-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to choose_cipher('DES-CBC3-SHA').via_proxy(https_proxy)

      stub_ssl_socket(cipher: nil)
      expect('www.example.com:443')
        .not_to choose_cipher('AES256-SHA').via_proxy(https_proxy)
    end

    it 'can evalutate choose cipher specified with protocol' do
      stub_ssl_socket(cipher: ['AES256-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to choose_cipher('AES256-SHA').protocol('TLSv1')
    end

    # show default description
    it do
      stub_ssl_socket(cipher: ['DES-CBC3-SHA', 'TLSv1/SSLv3', 168, 168])
      expect('www.example.com:443')
        .to(choose_cipher('DES-CBC3-SHA')
              .protocol('TLSv1')
              .from(['AES256-SHA', 'AES128-SHA', 'DES-CBC3-SHA']))
    end
  end
end
