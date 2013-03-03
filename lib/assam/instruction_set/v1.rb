module Assam
  module InstructionSet
    class V1
      def self.instructions
        @@instructions ||= {}
      end

      def self.instruction_codes
        @@instruction_codes ||= {}
      end

      def self.instruction name, opts = {}, &block
        instruction = opts.merge(block: block, name: name)

        if instructions[instruction[:name]] or instruction_codes[instruction[:opcode]]
          raise "Conflicting instruction: #{instruction}"
        end

        instructions[instruction[:name]]        = instruction
        instruction_codes[instruction[:opcode]] = instruction
      end

      instruction :nop, opcode: 0x00, args: 0 do
        # NOP - Do nothing.
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

      instruction :int, opcode: 0x06, args: 1, argsize: 1 do |signal|
        handler = interrupt_handler[signal]

        # If a handler exist for this interrupt, execute it. If not, no worries.
        # Just silently pass over it.
        if handler
          instance_eval(&handler)
        else
          Assam.logger.debug "Interrupt 0x#{signal.to_s(16)} fired but no " +
            "handler exists for that signal. Skipping."
        end
      end
    end
  end
end
