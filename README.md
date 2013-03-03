# Assam

## What is Assam?

Assam is essentially nothing. It's not useful in any practical way. It's one
curious human's attempt at applying his knowledge of how processors work and
exploring what it takes to plan out an instruction set / architecture.

So with that out of the way, this is an attempt at creating a virtual processor
in Ruby. I can see it already on HN: "Want to learn nothing about processors
with Ruby? Check this out!". I know, it's a ridiculous thing to do but in the
great words of George Mallory:

    "[I did it] because it's there."

### Why the name Assam?

I like tea. My name is Sam. This is sort of an assembler project. The three seem
to tie in very nicely.

## Rationale

This wasn't entirely meant as a learning exercise. I've recently been very
interested in branch prediction and wanted to have a go at running some of the
algorithms at a high level (again, in Ruby, sue me). Seeing as it's such a huge
problem in processor design I assumed that there would be data sets of branch
targets and whether they failed or succeeded but, alas, I could find nothing of
the sort.

The idea was to have a dataset to practice on and run algorithms over that,
outputting the prediction rate and various other measures of success. After
failing to find any data, I decided I'd write my own virtual processor and
generate my own test data.

This has got a little out of hand and now it seems I'm just working on building
a virtual processor. Never mind. I'm happy :)

## Installation

None as yet. It's not a gem or anything, it's pre-alpha and it's just a pet
project. The code is fairly documented, so if you want to clone it and have a
poke around then feel free.

The specs and samples are probably the best places to start. They'll give you an
idea of how to run Assam's assembler and whatnot.

## Sample Assam processor and program

``` ruby
require File.join('.', File.dirname(__FILE__), '..', 'lib', 'assam')

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

# Result of dumping registers:
#    eax: 0x0001 (1)
#    ebx: 0x000b (11)
#    ecx: 0x0005 (5)
#    edx: 0x0000 (0)
#    esp: 0x10000 (65536)
#    ebp: 0x0000 (0)
#    esi: 0x0000 (0)
#    edi: 0x0000 (0)
#     pc: 0x101b (4123)
# eflags: 0x0000 (0)
```
