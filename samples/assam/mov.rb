require_relative '../../lib/assam'

# Initialise a processor object.
processor = Assam::Processor.new

# Create a program for the processor.
prog = Assam::Program.new(processor) do
  mov 3, @ebx
  mov 5, @ecx

  add 8, @ebx

  mov 1, @eax
  int 0x80
end

# Assemble the program into machine code that the processor can understand.
binary = Assam::Assembler.new(processor, prog).assemble

# Load the binary machine code into the processor's memory. It will
# automatically be loaded into where code is supposed to start. Then run the
# code.
processor.load(binary).run

# Dump the state of the registers after the code has run.
processor.dump_registers
