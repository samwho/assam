module Assam
  class Processor
    # Codes to represent where an operand's data is coming from.
    IMMEDIATE  = 0x10 # Immediate value: int
    REGISTER   = 0x20 # Value stored in register.
    EXTERNAL   = 0x30 # Value stored in memory.
    EXPRESSION = 0x40 # Memory expression. Used with EXTERNAL.
    DIRECT     = 0x50 # Direct memory address. Used with EXTERNAL.
    MEM_ADD    = 0x60 # Addition symbol. Used with EXPRESSION.
    MEM_MUL    = 0x70 # Multiplication symbol. Used with EXPRESSION.
    MEM_SUB    = 0x80 # Subtraction symbol. Used with EXPRESSION.

    def initialize
      # 0x80 is the signal the Linux kernel uses for system calls. Just
      # emulating it slightly here in order to implement the ability to exit a
      # process.
      handler_for 0x80 do
        case registers[:eax].value
        when 0x01
          registers[:eflags].stop = true
        end
      end
    end

    # The instruction set object to use for this processor.
    def instruction_set
      @instruction_set ||= Assam::InstructionSet::V1
    end

    # The Assam::Memory object that represents a processor's RAM.
    def ram
      @ram ||= Memory.new(2 ** (8 * address_size), "RAM")
    end

    # The Assam::Memory object that represents a processor's register memory,
    # which in my theoretical architecture is used to hold the values for all
    # registers. Registers just offset differently into it.
    def register_memory
      @register_memory ||= Memory.new(256, "Register Memory")
    end

    # The address size of the processor expressed in bytes. Be careful when
    # modifying this because it's used when initialising the RAM. I initialised
    # it to 4 once and it brought my PC to its knees trying to allocate a 4GB
    # binary string.
    #
    # You have been warned :)
    def address_size
      @address_size ||= 2 # Expressed in bytes
    end

    # The point in memory that a program is loaded into before running. None of
    # this fancy virtual memory or multitaking is implemented, so it's one
    # program at a time I'm afraid. Be careful with your DMAs around this area,
    # there's no memory protection either.
    def code_start
      @code_start ||= 0x1000
    end

    # The point in memory where the stack starts. Typically this is always at
    # the top and grows down.
    def stack_start
      @stack_start ||= ram.size
    end

    # A hash of interrupt handlers keyed by the interrupt signal number.
    def interrupt_handler
      @interrupt_handler ||= {}
    end

    # Define an interrupt handler for a specific signal.
    def handler_for signal, &block
      interrupt_handler[signal] = block
    end

    # The registers hash! I've gone for an x86 inspired register set. It's not
    # complete but it doesn't need to be yet, and it's easy enough to extend
    # should one be so inclined.
    def registers
      @registers ||= {
        eax: Register.new(:eax, 0x00, 0x00, 4, register_memory),
        ebx: Register.new(:ebx, 0x01, 0x04, 4, register_memory),
        ecx: Register.new(:ecx, 0x02, 0x08, 4, register_memory),
        edx: Register.new(:edx, 0x03, 0x0c, 4, register_memory),
        esp: Register.new(:esp, 0x04, 0x10, 4, register_memory),
        ebp: Register.new(:ebp, 0x05, 0x14, 4, register_memory),
        esi: Register.new(:esi, 0x06, 0x18, 4, register_memory),
        edi: Register.new(:edi, 0x07, 0x1c, 4, register_memory),

        pc: Register.new(:pc, 0x08, 0x20, address_size, register_memory),
        eflags: Eflags.new,
      }
    end

    # Simple mapping of registers so their opcodes are their keys. Where the
    # #registers hash is keyed by a symbolized version of the register name
    # (e.g. eax is :eax), this is keyed by the register's opcode. Mainly for
    # internal use.
    def register_codes
      @register_codes ||= @registers.inject({}) do |memo, (_, r)|
        memo[r.opcode] = r
        memo
      end
    end

    # Reads a number of bytes from RAM (defaults to 1) and then increments the
    # program counter by that amount, returning the value read from RAM.
    #
    # Used internally for running programs, be _very_ careful using it manually.
    def ram_read size = 1
      pc   = registers[:pc].value
      read = ram[pc, size]

      registers[:pc].value += size

      read
    end

    # Loads a program binary string into RAM at a location specified by
    # #code_start, which is where the program counter will default to.
    def load program_binary
      Assam.logger.debug "Loading program into RAM: " +
        "#{Utils.binary_str_to_bytes(program_binary)}"

      ram[code_start, program_binary.length] = program_binary
      self
    end

    # Runs whatever is currently loaded at the #code_start location in RAM. If
    # there's nothing in there, RAM defaults everything to 0, so the processor
    # will start executing opcode 0 over and over.
    #
    # Hey, nobody said processors could read minds.
    def run
      # Set the program counter to the point in memory where code begins.
      registers[:pc].value = code_start

      # Set the stack pointer to the point in memory where the stack starts.
      registers[:esp].value = stack_start

      loop do
        # If the stop flag is set, unset it and break out of the program loop.
        if registers[:eflags].stop
          registers[:eflags].stop = false
          break
        end

        opcode      = ram_read
        instruction = instruction_set.instruction_codes[opcode]

        if instruction.nil?
          raise "Invalid opcode: 0x#{opcode.to_s(16)}. " +
            "PC: 0x#{registers[:pc].value.to_s(16)}"
        end

        arguments = []
        instruction[:args].times do
          case ram_read
          when IMMEDIATE
            arguments << ram_read(instruction[:argsize])
          when REGISTER
            register = register_codes[ram_read]
            arguments << MemoryLocation.from(register)
          when EXTERNAL
            arguments << MemoryLocation.new(ram, eval_memory_expression,
                                            instruction[:argsize])
          end
        end

        Assam.logger.debug "Running: #{instruction[:name]}, " +
          "args: #{arguments.inspect}"

        instance_exec(*arguments, &instruction[:block])
      end

      self
    end

    # Pretty prints all of the processor's registers and what their values are
    # in hex. For debugging purposes.
    def dump_registers
      registers.each do |name, register|
        puts "#{name.to_s.rjust(6)}: " +
          "0x#{register.value.to_s(16).rjust(register.size, "0")} " +
          "(#{register.value})"
      end
    end

    private

    # I don't always make a method private, but when I do it's because I can
    # honestly think of no good reason to use it outside of the context of
    # running a program on the virtual processor.
    #
    # The purpose of this method is to read a variable length memory addressing
    # mode for an instruction. It's very complex and hugely prone to error if
    # used incorrectly. Be careful.
    def eval_memory_expression
      Assam.logger.debug "Starting memory access..."

      case ram_read
      when DIRECT
        # Direct memory reference, just read a memory address from RAM and
        # return it.
        value = ram_read(address_size)

        Assam.logger.debug "Direct memory access. Read: #{value}"
        return value
      when REGISTER
        # Register reference. Read the register code from memory, look it up in
        # the register table and return the value.
        register = register_codes[ram_read]

        if register.nil?
          raise "Attempted to access a register that does not exist."
        else
          Assam.logger.debug "Register value memory access. Read: #{register.value}"
          return register.value
        end
      when EXPRESSION
        size       = ram_read
        pc         = MemoryLocation.from(registers[:pc])
        initial_pc = pc.read
        expression = []

        # Read the expression up until the size has been reached.
        until pc.read == (initial_pc + size)
          case ram_read
          when REGISTER
            expression << register_codes[ram_read].value
          when DIRECT
            expression << ram_read(address_size)
          when MEM_ADD
            expression << :+
          when MEM_SUB
            expression << :-
          when MEM_MUL
            expression << :*
          end
        end

        Assam.logger.debug "Memory expression disassembled: #{expression}"

        # We want to find if there's a multiplier and then group it with its
        # left and right operands so it gets evaluated in the correct
        # precedence.
        mul = expression.find_index :*

        # Messyish bit of code but all it does is turn something like:
        #   [1, :+, 2, :*, 3]
        #
        # Into:
        #
        #   [1, :+, 6]
        if mul
          # Grab the left and right sides of the expression.
          left = expression[mul - 1]
          right = expression[mul + 1]

          # Multiply them and insert them back into the expression.
          expression[(mul - 1)..(mul + 1)] = left * right
        end

        # Initialise the memory_location to the first value in expression.
        memory_location = expression.shift

        # Loop over the rest of the expression two elements at a time, modifying
        # the memory location appropriately as we go along.
        expression.each_slice(2) do |op, val|
          memory_location = memory_location.send(op, val)
        end

        Assam.logger.debug "Calculated memory expression to refer to " +
          "0x#{memory_location.to_s(16)} which currently holds the value " +
          "0x#{ram[memory_location, 1]}"
        return memory_location
      end
    end
  end
end
