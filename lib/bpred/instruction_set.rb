module Bpred
  class InstructionSet
    INSTRUCTIONS      = {}
    INSTRUCTION_CODES = {}

    def self.instruction name, opts = {}, &block
      instruction = opts.merge(block: block, name: name)

      INSTRUCTIONS[instruction[:name]]        = instruction
      INSTRUCTION_CODES[instruction[:opcode]] = instruction
    end

    instruction :nop, opcode: 0x00, args: 0 do
      # NOP - Do nothing.
    end

    instruction :stop, opcode: 0x01, args: 0 do
      # The logic of this will be handled externally for now.
    end

    instruction :mov, opcode: 0x02, args: 2, argsize: 2 do |src, dest|
      if src.is_a? Register
        if dest.is_a? Register
          dest.value = src.value
        elsif dest.is_a? Array
          Processor::RAM[dest, 2] = src.value
        end
      elsif src.is_a? Fixnum
        if dest.is_a? Register
          dest.value = src.to_i
        elsif dest.is_a? Array
          Processor::RAM[dest, 2] = src.to_i
        end
      else
        # Error case: dest needs to be a Register or memory location
      end
    end
  end
end
