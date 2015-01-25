require 'spec_helper'
require 'rspec_ssltls'

describe RspecSsltls::Util do
  describe '#self.open_socket' do
    before :each do
      proxy = double('proxy')
      allow(proxy).to receive(:open).and_return(:proxy)
      allow(Net::SSH::Proxy::HTTP).to receive(:new).and_return(proxy)
      allow(TCPSocket).to receive(:open).and_return(:direct)
    end

    context 'when options[:proxy] specified' do
      let(:uri) { URI.parse('https://www.example.com/') }
      let(:proxy_url) { 'http://proxy.example.com' }

      it 'should connect target via specified proxy server' do
        socket = described_class.open_socket(uri, proxy: proxy_url)
        expect(socket).to eq(:proxy)
      end
    end

    context 'when options[:proxy] is nil' do
      let(:uri) { URI.parse('https://www.example.com/') }
      let(:proxy_url) { nil }

      it 'should connect target directly' do
        socket = described_class.open_socket(uri, proxy: proxy_url)
        expect(socket).to eq(:direct)
      end
    end
  end

  describe '#self.build_uri' do
    context 'when String is given' do
      let(:source) { 'http://proxy.example.com:3128/' }
      it do
        uri = described_class.send(:build_uri, source)
        expect(uri).to eq URI.parse('http://proxy.example.com:3128/')
      end
      context 'when scheme is missing' do
        let(:source) { 'proxy.example.com' }
        it 'should complete http:// as default scheme' do
          uri = described_class.send(:build_uri, source)
          expect(uri).to eq URI.parse('http://proxy.example.com:80/')
        end
      end
    end

    context 'when not String is given' do
      let(:source) { URI.parse('http://proxy.example.com/') }
      it 'should return same object as given' do
        uri = described_class.send(:build_uri, source)
        expect(uri) == source
      end
    end
  end
end
