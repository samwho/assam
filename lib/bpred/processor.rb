module Bpred
  class Processor
    ADDRESS_SIZE    = 2
    REGISTER_MEMORY = Memory.new(256)
    RAM             = Memory.new(2 ** (8 * ADDRESS_SIZE))
    CODE_START      = 0x1000

    # Codes to represent where an operand's data is coming from.
    IMMEDIATE = 0x10
    REGISTER  = 0x20
    EXTERNAL  = 0x30

    REGISTERS = {
      eax: Register.new(:eax, 0x00, 0x00, 4, REGISTER_MEMORY),
      ebx: Register.new(:ebx, 0x01, 0x04, 4, REGISTER_MEMORY),
      ecx: Register.new(:ecx, 0x02, 0x08, 4, REGISTER_MEMORY),
      edx: Register.new(:edx, 0x03, 0x0c, 4, REGISTER_MEMORY),
      esp: Register.new(:esp, 0x04, 0x10, 4, REGISTER_MEMORY),
      ebp: Register.new(:ebp, 0x05, 0x14, 4, REGISTER_MEMORY),
      esi: Register.new(:esi, 0x06, 0x18, 4, REGISTER_MEMORY),
      edi: Register.new(:edi, 0x07, 0x1c, 4, REGISTER_MEMORY),

      pc: Register.new(:pc, 0x08, 0x20, ADDRESS_SIZE, REGISTER_MEMORY),
    }

    # Simple mapping of registers so their opcodes are their keys.
    REGISTER_CODES = REGISTERS.inject({}) do |memo, (_, r)|
      memo[r.opcode] = r
      memo
    end

    def self.ram_read size = 1
      pc   = REGISTERS[:pc].value
      read = RAM[pc, size]

      REGISTERS[:pc].value += size

      read
    end

    def self.load program_binary
      RAM[CODE_START, program_binary.length] = program_binary
      self
    end

    def self.run
      # Set the program counter to the point in memory where code begins.
      REGISTERS[:pc].value = CODE_START

      loop do
        opcode      = ram_read
        instruction = InstructionSet::INSTRUCTION_CODES[opcode]

        raise "Invalid opcode: #{opcode.to_s(16)}" if instruction.nil?
        break if instruction[:name] == :stop

        arguments = []
        instruction[:args].times do
          case ram_read
          when IMMEDIATE
            arguments << ram_read(instruction[:argsize])
          when REGISTER
            arguments << REGISTER_CODES[ram_read]
          when EXTERNAL
            # TODO: This.
          end
        end

        Bpred.logger.debug "Running: #{instruction[:name]}, args: #{arguments.inspect}"
        instruction[:block].call(*arguments)
      end

      self
    end

    def self.dump_registers
      REGISTERS.each do |name, register|
        puts "#{name.to_s.rjust(5)}: " +
          "0x#{register.value.to_s(16).rjust(register.size, "0")} " +
          "(#{register.value})"
      end
    end
  end
end
