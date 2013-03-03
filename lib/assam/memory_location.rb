module Assam
  # This class exists as a way for passing memory locations to an instruction.
  # It exposes basic read and write operations to a specified bank of memory.
  class MemoryLocation
    def self.from arg
      MemoryLocation.new(arg.memory, arg.location, arg.size)
    end

    def initialize memory, location, size
      @memory   = memory
      @location = location
      @size     = size
    end

    def read opts = {}
      @memory.load(@location, @size, opts)
    end

    def write new_value, opts = {}
      @memory.store(@location, @size, new_value, opts)
    end

    def to_s
      "<MemoryLocation \"#{@memory.name}\":0x#{@location.to_s(16)}:#{@size}>"
    end
  end
end
