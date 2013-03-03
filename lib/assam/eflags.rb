module Assam
  # Flags documentation from:
  #
  #   http://www.c-jump.com/CIS77/ASM/Instructions/I77_0070_eflags_bits.htm
  #
  # 0   CF Carry Flag: Set by arithmetic instructions which generate either a
  # carry or borrow. Set when an operation generates a carry to or a borrow from
  # a destination operand.
  #
  # 2   PF Parity flag: Set by most CPU instructions if the least significant
  # (aka the low-order bits) of the destination operand contain an even number
  # of 1's.
  #
  # 4   AF Auxiliary Carry Flag: Set if there is a carry or borrow involving bit
  # 4 of EAX. Set when a CPU instruction generates a carry to or a borrow from
  # the low-order 4 bits of an operand. This flag is used for binary coded
  # decimal (BCD) arithmetic.
  #
  # 6   ZF Zero Flag: Set by most instructions if the result an operation is
  # binary zero.
  #
  # 7   SF Sign Flag: Most operations set this bit the same as the most
  # significant bit (aka high-order bit) of the result. 0 is positive, 1 is
  # negative.
  #
  # 8   TF Trap Flag: (sometimes named a Trace Flag.) Permits single stepping of
  # programs. After executing a single instruction, the processor generates an
  # internal exception 1. When Trap Flag is set by a program, the processor
  # generates a single-step interrupt after each instruction. A debugging
  # program can use this feature to execute a program one instruction at a time.
  #
  # 9   IF Interrupt Enable Flag: when set, the processor recognizes external
  # interrupts on the INTR pin. When set, interrupts are recognized and acted on
  # as they are received. The bit can be cleared to turn off interrupt
  # processing temporarily.
  #
  # 10   DF Direction Flag: Set and cleared using the STD and CLD instructions.
  # It is used in string processing. When set to 1, string operations process
  # down from high addresses to low addresses. If cleared, string operations
  # process up from low addresses to high addresses.
  #
  # 11   OF Overflow Flag: Most arithmetic instructions set this bit, indicating
  # that the result was too large to fit in the destination. When set, it
  # indicates that the result of an operation is too large or too small to fit
  # in the destination operand.
  #
  # 12-13  IOPL Input/Output privilege level flags: Used in protected mode to
  # generate four levels of security.
  #
  # 14   NT Nested Task Flag: Used in protected mode. When set, it indicates
  # that one system task has invoked another via a CALL Instruction, rather than
  # a JMP.
  #
  # 16   RF Resume Flag: Used by the debug registers DR6 and DR7. It enables you
  # to turn off certain exceptions while debugging code.
  #
  # 17   VM Virtual 8086 Mode flag: Permits 80386 to behave like a high speed
  # 8086.
  class Eflags < Register
    BITS = {
      cf:    0,
      stop:  1,
      pf:    2,
      af:    4,
      zf:    6,
      sf:    7,
      tf:    8,  # Not used
      if:    9,
      df:    10, # Not used
      of:    11,
      nt:    14, # Not used
      rf:    16, # Not used
      v8086: 17, # Not used
    }

    def initialize
      super :eflags, 0xFF, 0x00, 4, Memory.new(4, "EFLAGS")
    end

    # Define getters and setters for each of the bits defined in the BITS hash.
    BITS.each do |key, val|
      define_method("#{key}")  { get_bit(val) }
      define_method("#{key}=") { |bool| set_bit(val, bool) }
    end

    private

    def set_bit number, bool
      mask = 2 ** number

      if get_bit(number) == true and bool == false
        self.value = self.value - mask
      elsif get_bit(number) == false and bool == true
        self.value = self.value + mask
      end

      return bool
    end

    def get_bit number
      mask = 2 ** number
      (self.value & mask) == mask
    end
  end
end
