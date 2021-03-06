module Assam
  class Program
    attr_accessor :instructions

    def initialize processor, opts = {}, &block
      @opts = opts
      @processor = processor

      # Initialise instance variables as registers.
      processor.registers.each do |name, register|
        instance_variable_set "@#{name}".to_sym, register
      end

      # A list of nodes that will eventually get run as a program.
      @instructions = []

      instance_eval(&block)
    end

    # Any time a method is called that is not defined, it is put into the
    # @instructions array. This allows us to build a list of instructions that
    # are in order, which will allow us to jump around the program later on (for
    # branches and whatnot).
    def method_missing name, *args
      @instructions << [name, *args]
    end
  end
end
