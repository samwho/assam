module Assam
  class Eflags < Register
    BITS = {
      :stop      => 0,
      :carry     => 1,
      :zero      => 2,
    }

    def initialize
      super :eflags, 0xFF, 0x00, 4, Memory.new(4, "EFLAGS")
    end

    # Define getters and setters for each of the bits defined in the BITS hash.
    BITS.each do |key, val|
      define_method key do
        get_bit(val)
      end

      define_method "#{key}=" do |bool|
        set_bit(val, bool)
      end
    end

    private

    def set_bit number, bool
      mask = 2 ** number

      if get_bit(number) == true and bool == false
        self.value = self.value - mask
      elsif get_bit(number) == false and bool == true
        self.value = self.value + mask
      end

      return bool
    end

    def get_bit number
      mask = 2 ** number
      (self.value & mask) == mask
    end
  end
end
