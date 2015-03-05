# rspec-ssltls [![Build Status](https://travis-ci.org/otahi/rspec-ssltls.png?branch=master)](https://travis-ci.org/otahi/rspec-ssltls)[![Coverage Status](https://coveralls.io/repos/otahi/rspec-ssltls/badge.png?branch=master)](https://coveralls.io/r/otahi/rspec-ssltls?branch=master)[![Code Climate](https://codeclimate.com/github/otahi/rspec-ssltls.png)](https://codeclimate.com/github/otahi/rspec-ssltls)[![Gem Version](https://badge.fury.io/rb/rspec-ssltls.png)](http://badge.fury.io/rb/rspec-ssltls)


Rspec-ssltls is an rspec plugin for easy SSL/TLS testing with Ruby standard OpenSSL library.

## Usage

RSpec-ssltls is best described by example. First, require `rspec_ssltls` in your `spec_helper.rb`:

```ruby
# spec/spec_helper.rb
require 'rspec_ssltls'
```

Then, create a spec like this:

```ruby
require 'spec_helper'

describe 'www.example.com:443' do
  it { is_expected.to have_certificate.subject(CN: '*.example.com') }
  it { is_expected.to have_certificate.issuer(CN: 'ca.example.org') }
  it { is_expected.to have_certificate.chain(0).subject(CN: '*.example.com') }
  it do
    is_expected.to have_certificate
      .subject(CN: '*.example.com').valid_at('2020/09/12 19:00:05 JST')
  end
  it do
    is_expected.to have_certificate
      .subject(CN: '*.example.com')
      .valid_in('2014/09/12 19:00:05 UTC', '2015/10/01 00:00:00 UTC')
  end
  it do
    is_expected.to have_certificate
      .subject(CN: '*.example.com').signature_algorithm('sha1WithRSAEncryption')
  end
  it { is_expected.to have_certificate.verified }
  it do
    is_expected.to have_certificate
      .verified_with(File.read('example.org.cer'))
  end
  it { is_expected.to support_protocol('TLSv1_2') }
  it { is_expected.to support_cipher('AES256-SHA').protocol('TLSv1') }
  it { is_expected.to support_cipher('DES-CBC3-SHA').protocol('SSLv3') }
end
```

You can use `via_proxy` chain to specify https_proxy server.
```ruby
describe 'www.example.com:443' do
  it do
    is_expected.to have_certificate
      .subject(CN: '*.example.com').valid_at('2020/09/12 19:00:05 JST')
      .via_proxy('http://user:pass@proxy.example.com:3128/')
  end
end
```

You can also specify https_proxy server with `RSpec.configuration.rspec_ssltls_https_proxy`
as global configuration.
```
RSpec.configuration.rspec_ssltls_https_proxy = 'http://proxy.example.com:3128'

```
or
```
RSpec.configuration.rspec_ssltls_https_proxy = ENV['https_proxy']
```

You can use followings for `support_protocol` and `support_cipher.protocol`:
```
 OpenSSL::SSL::SSLContext::METHODS
  :TLSv1, :TLSv1_server, :TLSv1_client,
  :TLSv1_2, :TLSv1_2_server, :TLSv1_2_client,
  :TLSv1_1, :TLSv1_1_server, :TLSv1_1_client,
  :SSLv2, :SSLv2_server, :SSLv2_client,
  :SSLv3, :SSLv3_server, :SSLv3_client,
  :SSLv23, :SSLv23_server, :SSLv23_client
```

You can use [ciphers](https://www.openssl.org/docs/apps/ciphers.html) for `support_cipher`.

You can use [signature algorithm](https://github.com/openssl/openssl/blob/master/crypto/objects/obj_xref.txt) for `signature_algorithm`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-ssltls'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-ssltls

## Contributing

1. Fork it ( https://github.com/otahi/rspec-ssltls/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
