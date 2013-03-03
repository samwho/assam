require File.join('.', File.dirname(__FILE__), '..', 'lib', 'assam')
require 'pp'

processor = Assam::Processor.new

prog = Assam::Program.new do
  mov 3, @eax

  stop
end

binary = Assam::Assembler.new(prog).assemble

processor.load(binary).run
processor.dump_registers
