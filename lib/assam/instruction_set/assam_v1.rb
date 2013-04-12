module Assam
  module InstructionSet
    class AssamV1
      def self.instructions
        @@instructions ||= {}
      end

      def self.instruction_codes
        @@instruction_codes ||= {}
      end

      def self.instruction name, opts = {}, &block
        instruction = opts.merge(block: block, name: name, args: block.arity)

        if instructions[name] or instruction_codes[instruction[:opcode]]
          raise "Conflicting instruction: #{instruction}"
        end

        instructions[instruction[:name]]        = instruction
        instruction_codes[instruction[:opcode]] = instruction
      end

      instruction :nop, opcode: 0x00 do
        # NOP - Do nothing.
      end

      instruction :mov, opcode: 0x02, argsize: 2 do |src, dest|
        opts = { signed: true }

        if src.is_a? MemoryLocation and dest.is_a? MemoryLocation
          dest.write(src.read(opts), opts)
        elsif src.is_a? Fixnum and dest.is_a? MemoryLocation
          dest.write(src.to_i, opts)
        else
          # Error case: dest needs to be a Register or memory location
        end
      end

      instruction :add, opcode: 0x03, argsize: 2 do |src, dest|
        opts = { signed: true }

        if src.is_a? MemoryLocation and dest.is_a? MemoryLocation
          dest.write(dest.read(opts) + src.read(opts), opts)
        elsif src.is_a? Fixnum and dest.is_a? MemoryLocation
          dest.write(dest.read(opts) + src.to_i, opts)
        else
          # Error case: dest needs to be a Register
        end
      end

      instruction :sub, opcode: 0x04, argsize: 2 do |src, dest|
        opts = { signed: true }

        if src.is_a? MemoryLocation and dest.is_a? MemoryLocation
          dest.write(dest.read(opts) - src.read(opts), opts)
        elsif src.is_a? Fixnum and dest.is_a? MemoryLocation
          dest.write(dest.read(opts) - src.to_i, opts)
        else
          # Error case: dest needs to be a Register
        end
      end

      instruction :push, opcode: 0x05, argsize: 2 do |src|
        # Can push a value or memory location to stack. Handle these and store th
        # actual value to be stored inside value.
        value = src.read if src.is_a? MemoryLocation
        value = src.to_i if src.is_a? Fixnum

        # Push to the stack by setting the memory location pointed at by @esp and
        # then decrementing the stack pointer.
        registers[:esp].value -= 2
        ram[registers[:esp].value, 2] = value
      end

      instruction :pop, opcode: 0x06, argsize: 2 do |dest|
        raise "Invalid destination for :pop." unless dest.is_a? MemoryLocation

        value = ram[registers[:esp].value, 2]
        registers[:esp].value += 2

        dest.write(value)
      end

      instruction :int, opcode: 0x07, argsize: 1 do |signal|
        # If the interrupt flags is set, continue.
        if registers[:eflags].if
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

      # Documentation for test and how it sets flags can be found here:
      #
      #   http://en.wikibooks.org/wiki/X86_Assembly/Control_Flow
      instruction :test, opcode: 0x08, argsize: 2 do |left, right|
        left  = left.is_a? MemoryLocation ? left.value : left.to_i
        right = right.is_a? MemoryLocation ? right.value : right.to_i

        test = left & right
        test
      end

      # Documentation for cmp and how it sets flags can be found here:
      #
      #   http://en.wikibooks.org/wiki/X86_Assembly/Control_Flow
      instruction :cmp, opcode: 0x09, args: 2, argsize: 2 do |left, right|

      end
    end
  end
end
