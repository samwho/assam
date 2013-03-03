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

    instruction :push, opcode: 0x04, args: 1, argsize: 2 do |src|
      # Can push a value or memory location to stack. Handle these and store th
      # actual value to be stored inside value.
      value = src.read if src.is_a? MemoryLocation
      value = src.to_i if src.is_a? Fixnum

      # Push to the stack by setting the memory location pointed at by @esp and
      # then decrementing the stack pointer.
      registers[:esp].value -= 2
      ram[registers[:esp].value, 2] = value
    end

    instruction :pop, opcode: 0x05, args: 1, argsize: 2 do |dest|
      raise "Invalid destination for :pop." unless dest.is_a? MemoryLocation

      value = ram[registers[:esp].value, 2]
      registers[:esp].value += 2

      dest.write(value)
    end
  end
end
