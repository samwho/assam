module Assam
  class InstructionSet
    INSTRUCTIONS      = {}
    INSTRUCTION_CODES = {}

    def self.instruction name, opts = {}, &block
      instruction = opts.merge(block: block, name: name)

      if INSTRUCTIONS[instruction[:name]] or INSTRUCTION_CODES[instruction[:opcode]]
        raise "Conflicting instruction: #{instruction}"
      end

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
      if src.is_a? MemoryLocation and dest.is_a? MemoryLocation
        dest.write(src.read)
      elsif src.is_a? Fixnum and dest.is_a? MemoryLocation
        dest.write(src.to_i)
      else
        # Error case: dest needs to be a Register or memory location
      end
    end

    instruction :add, opcode: 0x03, args: 2, argsize: 2 do |src, dest|
      if src.is_a? MemoryLocation and dest.is_a? MemoryLocation
        dest.write(dest.read + src.read)
      elsif src.is_a? Fixnum and dest.is_a? MemoryLocation
        dest.write(dest.read + src.to_i)
      else
        # Error case: dest needs to be a Register
      end
    end
  end
end
