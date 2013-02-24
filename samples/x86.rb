require File.join('.', File.dirname(__FILE__), '..', 'lib', 'bpred')
require 'pp'

# prog = Bpred::ISA::X86.new do
#   xor @eax, @eax
#   add 10, @eax

#   cmp @eax, 0

#   jne :exit

#   mov 3, @ebx

# label :exit

#   mov 1, @eax
# end

prog = Bpred::Program.new do
  mov 3, @eax

  stop
end

binary = Bpred::Assembler.new(prog).assemble

Bpred::Processor.load(binary).run
Bpred::Processor.dump_registers
