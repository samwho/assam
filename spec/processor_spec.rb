require 'spec_helper'

describe Assam::Processor do
  let(:binary) { Assam::Assembler.new(processor, program).assemble }
  before       { processor.load(binary).run }

  describe "very simple program" do
    let :program do
      Assam::Program.new(processor) do
        mov 3, @eax
        stop
      end
    end

    specify("@eax == 3") { eax.value.should == 3 }
  end

  describe "more complex program" do
    let :program do
      Assam::Program.new(processor) do
        mov 4, @eax
        mov 5, @ebx

        add @eax, @ebx

        stop
      end
    end

    specify("@eax == 4") { eax.value.should == 4 }
    specify("@ebx == 9") { ebx.value.should == 9 }
  end

  describe "direct memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 12, [0x8000]
        mov [0x8000], @eax

        stop
      end
    end

    specify("@eax == 12") { eax.value.should == 12 }
  end

  describe "register memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 0x8000, @eax
        mov 12, [@eax]
        mov [@eax], @ebx

        stop
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
    specify("@eax == 0x8000") { eax.value.should == 0x8000 }
  end

  describe "register offset memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 0x8000, @eax
        mov 12, [@eax + 12]
        mov [@eax + 12], @ebx

        stop
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
    specify("@eax == 0x8000") { eax.value.should == 0x8000 }
  end

  describe "register index size memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 0x8000, @eax
        mov 3, @edi
        mov 12, [@eax + @edi * 4]
        mov [@eax + @edi * 4], @ebx

        stop
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
    specify("@eax == 0x8000") { eax.value.should == 0x8000 }
  end

  describe "register index size offset memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 0x8000, @eax
        mov 3, @edi
        mov 12, [@eax + @edi * 4 + 12]
        mov [@eax + @edi * 4 + 12], @ebx

        mov 4, @edi
        mov 8, [@eax + @edi * 4 + 12]
        mov [@eax + @edi * 4 + 12], @ecx

        stop
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
    specify("@ecx == 8") { ecx.value.should == 8 }
    specify("@eax == 0x8000") { eax.value.should == 0x8000 }
  end

  describe "stack push and pop" do
    let :program do
      Assam::Program.new(processor) do
        push 12
        push 4
        push 6
        push 14

        pop @eax
        pop @ebx
        pop @ecx
        pop @edx

        stop
      end
    end

    specify("@eax == 14") { eax.value.should == 14 }
    specify("@ebx == 6") { ebx.value.should == 6 }
    specify("@ecx == 4") { ecx.value.should == 4 }
    specify("@edx == 12") { edx.value.should == 12 }
  end
end
