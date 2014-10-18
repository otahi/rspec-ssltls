# Easily test your SSL/TLS with RSpec.
module RspecSsltls
  # Utility class
  class Util
    def self.add_string(target, addition)
      if target.nil?
        target = ' ' + addition
      else
        target.join(addition, ' ')
      end
    end
  end
end
