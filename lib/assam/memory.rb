module Assam
  # Class for representing RAM in a virtual system. Stores bytes in a big endian
  # fashion (because little endian is a little more difficult to deal with in my
  # personal opinion).
  #
  # Examples:
  #
  #   # Allocate 256 bytes of ram.
  #   mem = Assam::Memory.new(256)
  #
  #   # Store some values in memory
  #   mem.store 0x10, 1, 0xFF
  #   mem.store 0x20, 4, 0x00FF00FF
  #
  #   # Retrieve them
  #   mem.load(0x00, 1) #=> 0
  #   mem.load(0x10, 1) #=> 0xFF (255)
  #
  #   mem.load(0x21, 1) #=> 0xFF (255)
  #   mem.load(0x22, 1) #=> 0
  class Memory
    attr_accessor :name, :size

    def initialize size, name = "Unnamed"
      @memory = Array.new(size, 0).pack("C*").force_encoding(Encoding::BINARY)
      @name = name
      @size = size
    end

    def load position, size, opts = {}
      @memory[position, size].unpack(Utils.unpack_for(size, opts)).first
    end

    def store position, size, value, opts = {}
      binary_value = nil

      if value.is_a? String
        binary_value = value.force_encoding(Encoding::BINARY)
      else
        binary_value = [value].pack(Utils.pack_for(size, opts))
      end

      @memory[position, size] = binary_value
    end

    def [] position, size
      self.load(position, size)
    end

    def []= position, size, value
      self.store(position, size, value)
    end

    def hexdump
      # TODO: Write a nicely formatted hex dumping method.
    end
  end
end
