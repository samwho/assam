require 'spec_helper'

describe Assam::Processor do
  let(:binary) { Assam::Assembler.new(processor, program).assemble }
  before       { processor.load(binary).run }

  describe "very simple program" do
    let :program do
      Assam::Program.new(processor) do
        mov 3, @ebx

        mov 1, @eax
        int 0x80
      end
    end

    specify("@ebx == 3") { ebx.value.should == 3 }
  end

  describe "more complex program" do
    let :program do
      Assam::Program.new(processor) do
        mov 4, @eax
        mov 5, @ebx

        add @eax, @ebx

        mov 1, @eax
        int 0x80
      end
    end

    specify("@eax == 1") { eax.value.should == 1 }
    specify("@ebx == 9") { ebx.value.should == 9 }
  end

  describe "direct memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 12, [0x8000]
        mov [0x8000], @ebx

        mov 1, @eax
        int 0x80
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
  end

  describe "register memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 0x8000, @eax
        mov 12, [@eax]
        mov [@eax], @ebx

        mov 1, @eax
        int 0x80
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
  end

  describe "register offset memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 0x8000, @eax
        mov 12, [@eax + 12]
        mov [@eax + 12], @ebx

        mov 1, @eax
        int 0x80
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
  end

  describe "register index size memory access" do
    let :program do
      Assam::Program.new(processor) do
        mov 0x8000, @eax
        mov 3, @edi
        mov 12, [@eax + @edi * 4]
        mov [@eax + @edi * 4], @ebx

        mov 1, @eax
        int 0x80
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
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

        mov 1, @eax
        int 0x80
      end
    end

    specify("@ebx == 12") { ebx.value.should == 12 }
    specify("@ecx == 8") { ecx.value.should == 8 }
  end

  describe "stack push and pop" do
    let :program do
      Assam::Program.new(processor) do
        push 12
        push 4
        push 6

        pop @ebx
        pop @ecx
        pop @edx

        mov 1, @eax
        int 0x80
      end
    end

    specify("@ebx == 6") { ebx.value.should == 6 }
    specify("@ecx == 4") { ecx.value.should == 4 }
    specify("@edx == 12") { edx.value.should == 12 }
  end
end
