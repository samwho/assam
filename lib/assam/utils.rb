module Assam
  class Utils
    SIGNED = true

    def self.pack_for size, opts = {}
      case size
      when 1
        opts[:signed] ? "c" : "C"
      when 2
        opts[:signed] ? "s>" : "S>"
      when 4
        opts[:signed] ? "l>" : "L>"
      when 8
        opts[:signed] ? "q>" : "Q>"
      end
    end

    def self.unpack_for size, opts = {}
      case size
      when 1
        opts[:signed] ? "c" : "C"
      when 2
        opts[:signed] ? "s>" : "S>"
      when 4
        opts[:signed] ? "l>" : "L>"
      when 8
        opts[:signed] ? "q>" : "Q>"
      end
    end

    def self.binary_str_to_bytes binary
      binary.unpack("C*").map { |byte| "0x#{byte.to_s(16).rjust(2, '0')}" }
    end
  end
end
