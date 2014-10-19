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
