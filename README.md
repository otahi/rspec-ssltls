# rspec-ssltls [![Build Status](https://travis-ci.org/otahi/rspec-ssltls.png?branch=master)](https://travis-ci.org/otahi/rspec-ssltls)[![Coverage Status](https://coveralls.io/repos/otahi/rspec-ssltls/badge.png?branch=master)](https://coveralls.io/r/otahi/rspec-ssltls?branch=master)[![Code Climate](https://codeclimate.com/github/otahi/rspec-ssltls.png)](https://codeclimate.com/github/otahi/rspec-ssltls)[![Gem Version](https://badge.fury.io/rb/rspec-ssltls.png)](http://badge.fury.io/rb/rspec-ssltls)


Rspec-ssltls is an rspec plugin for easy SSL/TLS testing.

## Usage

RSpec-ssltls is best described by example. First, require `rspec-ssltls` in your `spec_helper.rb`:

```ruby
# spec/spec_helper.rb
require 'rspec-ssltls'
```

Then, create a spec like this:

```ruby
require 'spec_helper'

describe 'www.example.com:443' do
  it { is_expected.to have_certificate.commonname('*.example.com') }
  it { is_expected.to support_protocol('TLSv1.2') }
  it { is_expected.to support_cipher('TLS_RSA_WITH_AES_256_CBC_SHA') }
end
```

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
