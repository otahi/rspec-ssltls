require 'spec_helper'
require 'rspec_ssltls'

def stub_ssl_socket(params)
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

describe 'rspec-ssltls matchers' do
  describe '#have_certificate' do
    it 'can evalutate having certificate' do
      stub_ssl_socket(peer_cert: 'CN=*.example.com')
      expect('www.example.com:443').to have_certificate
    end
  end
end
