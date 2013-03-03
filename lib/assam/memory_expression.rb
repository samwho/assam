module Assam
  class MemoryExpression
    attr_accessor :expression

    def initialize *args
      @expression = args
    end

    # This little hack is to allow the assembly code to have memory addressing
    # with registers in the offsets.
    #
    # Ways of addressing:
    #
    #   [0x4000]               #=> direct
    #   [@reg]                 #=> register
    #   [@reg + 2]             #=> register + offset
    #   [@reg * 4 + 2]         #=> register * data size + offset
    #   [@reg + @reg2]         #=> register + register
    #   [@reg + @reg2 * 4 + 2] #=> register * data size + offset
    def + offset
      [@expression, :+, offset].flatten
    end

    def * offset
      [@expression, :*, offset].flatten
    end

    def to_a
      @expression
    end

    # Some example usage:
    #
    #   @eax = Assam::Processor::REGISTERS[:eax]
    #   @ebx = Assam::Processor::REGISTERS[:ebx]
    #
    #   Assam::MemoryExpression.flatten [@eax + @ebx * 4 + 2].first
    #   #=> [@eax, :+, @ebx, :*, 4, :+, 2]
    #
    # Hackhackhack :)
    def self.flatten expression
      # Yo dawg, heard you like memory expressions.
      expression = expression.expression if expression.is_a? MemoryExpression

      expression.map do |part|
        if part.is_a? MemoryExpression
          part.to_a
        else
          part
        end
      end.flatten
    end
  end
end
