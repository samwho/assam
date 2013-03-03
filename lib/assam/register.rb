module Assam
  class Register
    attr_reader :name, :size, :location, :memory, :opcode

    def initialize name, opcode, location, size, memory
      @name     = name
      @opcode   = opcode
      @size     = size
      @location = location
      @memory   = memory
    end

    def value= new_value, opts = {}
      @memory.store(@location, @size, new_value, opts)
    end

    def value opts = {}
      @memory.load(@location, @size, opts)
    end

    def to_s
      "@#{@name.to_s}"
    end

    def + offset
      MemoryExpression.new self, :+, offset
    end

    def * offset
      MemoryExpression.new self, :*, offset
    end
  end
end
