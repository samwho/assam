module Assam
  class Utils
    def self.pack_for size
      case size
      when 1
        "C"
      when 2
        "S>"
      when 4
        "L>"
      when 8
        "Q>"
      end
    end

    def self.unpack_for size
      case size
      when 1
        "C"
      when 2
        "S>"
      when 4
        "L>"
      when 8
        "Q>"
      end
    end

    def self.binary_str_to_bytes binary
      binary.unpack("C*").map { |byte| "0x#{byte.to_s(16).rjust(2, '0')}" }
    end
  end
end
