module Assam
  module ELF
    # typedef struct{
    #   Elf32_Word sh_name;
    #   Elf32_Word sh_type;
    #   Elf32_Word sh_flags;
    #   Elf32_Addr sh_addr;
    #   Elf32_Off  sh_offset;
    #   Elf32_Word sh_size;
    #   Elf32_Word sh_link;
    #   Elf32_Word sh_info;
    #   Elf32_Word sh_addralign;
    #   Elf32_Word sh_entsize;
    # } Elf32_Shdr;
    class SectionHeader
      attr_accessor :shnum, :e_shentsize, :elf_reader, :sh_name, :sh_type,
        :sh_flags, :sh_addr, :sh_offset, :sh_size, :sh_link, :sh_info,
        :sh_addralign, :sh_entsize

      def initialize shnum, elf_reader, e_shentsize, elf_file
        @shnum       = shnum
        @e_shentsize = e_shentsize
        @elf_reader  = elf_reader

        @sh_name      = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @sh_type      = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @sh_flags     = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @sh_addr      = elf_file.read(ELF32_ADDR_SIZE).unpack(ELF32_ADDR).first
        @sh_offset    = elf_file.read(ELF32_OFF_SIZE).unpack(ELF32_OFF).first
        @sh_size      = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @sh_link      = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @sh_info      = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @sh_addralign = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @sh_entsize   = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
      end

      def name
        unless @name
          offset      = @elf_reader.string_table.sh_offset + @sh_name
          file        = @elf_reader.raw_file
          name_string = ""

          until file[offset, 1] == "\0"
            name_string << file[offset, 1]
            offset += 1
          end

          @name = name_string
        end

        @name
      end

      def content
        @content ||= @elf_reader.raw_file[@sh_offset, @sh_size]
      end
    end
  end
end
