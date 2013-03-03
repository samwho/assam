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

    def value= new_value
      @memory[@location, @size] = new_value
    end

    def value
      @memory[@location, @size]
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
