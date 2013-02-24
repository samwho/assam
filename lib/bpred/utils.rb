module Bpred
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
  end
end
