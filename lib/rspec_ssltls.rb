require 'rspec_ssltls/version'
require 'rspec/expectations'
require 'socket'
require 'openssl'

RSpec.configure do |c|
  c.add_setting :rspec_ssltls_https_proxy, default: nil
end

require 'rspec_ssltls/util'
require 'rspec_ssltls/have_certificate'
require 'rspec_ssltls/support_protocol'
require 'rspec_ssltls/support_cipher'
