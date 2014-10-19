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

# OpenSSL::SSL::SSLContext::METHODS
#  :TLSv1, :TLSv1_server, :TLSv1_client,
#  :TLSv1_2, :TLSv1_2_server, :TLSv1_2_client,
#  :TLSv1_1, :TLSv1_1_server, :TLSv1_1_client,
#  :SSLv2, :SSLv2_server, :SSLv2_client,
#  :SSLv3, :SSLv3_server, :SSLv3_client,
#  :SSLv23, :SSLv23_server, :SSLv23_client

describe 'rspec-ssltls matchers' do
  describe '#support_protocol' do
    it 'can evalutate support protocol' do
      expect('www.example.com:443').not_to support_protocol('SSLv3')
      stub_ssl_socket(ssl_version: 'TLSv1')
      expect('www.example.com:443').to support_protocol('TLSv1')
      expect('www.example.com:443').to support_protocol(:TLSv1)
      stub_ssl_socket(ssl_version: nil)
      expect('www.example.com:443').not_to support_protocol('SSLv3')
      expect('www.example.com:443').not_to support_protocol([:TLSv1, 'SSLv3'])
    end
  end
end
