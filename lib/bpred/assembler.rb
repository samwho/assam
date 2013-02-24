module Bpred
  class Assembler
    def initialize program
      @program      = program
      @address      = 0
      @labels       = {}
    end

    def assemble
      bytecodes = @program.instructions.map do |name, *args|
        if name == :label
          # As we skip through the code, labels will just be set to the current
          # relative address of the assembled program, exactly where the next
          # instruction will be located.
          @labels[args.first] = @address
        else
          instruction = InstructionSet::INSTRUCTIONS[name]

          if instruction.nil?
            raise "No such instruction: #{name}"
          end

          if args.size != instruction[:args]
            raise "Wrong number of args for #{name}: got #{args.size} expected " +
              "#{instruction[:args]}"
          end

          # Welcome to the genius/madness that is my assembler.
          #
          # Symbols are labels. Check the @labels hash for a relative program
          # address and store it as an immediate.
          #
          # A Register represents a... well, register. Store the type code for
          # registers and then the register's opcode.
          #
          # Arrays are memory references.
          #
          # Immediates are direct numerical values, the size of which are
          # dictated by what operation is being assembled.
          args.map! do |arg|
            case arg
            when Symbol
              [Processor::IMMEDIATE].pack("C") +
                [@labels[arg]].pack(Utils.pack_for(Processor::ADDRESS_SIZE))
            when Register
              [Processor::REGISTER, arg.opcode].pack("C*")
            when Array
              [Processor::EXTERNAL].pack("C") +
                [arg.first].pack(Utils.pack_for(Processor::ADDRESS_SIZE))
            else
              [Processor::IMMEDIATE].pack("C") +
                [arg].pack(Utils.pack_for(instruction[:argsize]))
            end
          end

          binary = [instruction[:opcode]].pack("C") + args.join('')

          logger.debug "Binary for #{name}: #{binary.unpack("C*")}"
          @address += binary.length
          binary
        end
      end

      bytecodes.join
    end
  end
end
