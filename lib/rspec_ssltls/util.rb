require 'net/ssh/proxy/http'

# Easily test your SSL/TLS with RSpec.
module RspecSsltls
  # Utility class
  class Util
    def self.add_string(target, addition, separator = ', ')
      if target.nil?
        ' ' + addition
      else
        target + separator + addition
      end
    end

    def self.invalid_ssl_tls_protocol(protocol)
      protocol = Set.new + [protocol] unless protocol.respond_to?(:map)
      invalid_protocol =
        (protocol.map { |a| a.to_s } -
          OpenSSL::SSL::SSLContext::METHODS.map { |a| a.to_s })
      invalid_protocol.size > 0 ? invalid_protocol : nil
    end

    def self.open_socket(uri, options = {})
      proxy = proxy_config(options)
      if proxy
        proxy_uri = build_uri(proxy)
        proxy_server = Net::SSH::Proxy::HTTP.new(proxy_uri.host,
                                                 proxy_uri.port,
                                                 user: proxy_uri.user,
                                                 password: proxy_uri.password)
        proxy_server.open(uri.host, uri.port)
      else
        TCPSocket.open(uri.host, uri.port)
      end
    end

    def self.proxy_config(options = {})
      options[:proxy] ? options[:proxy] :
        RSpec.configuration.rspec_ssltls_https_proxy
    end

    def self.build_uri(source)
      if source.is_a?(String)
        source = 'http://' + source unless source.start_with?('http://')
        URI.parse(source)
      else
        source
      end
    end

    private_class_method :proxy_config
    private_class_method :build_uri
  end
end
