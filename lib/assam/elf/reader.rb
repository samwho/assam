module Assam
  module ELF
    # C struct of what the ELF header should look like.
    #
    #   define EI_NIDENT 16
    #   typedef struct{
    #     unsigned char e_ident[EI_NIDENT];
    #     Elf32_Half    e_type;
    #     Elf32_Half    e_machine;
    #     Elf32_Word    e_version;
    #     Elf32_Addr    e_entry;
    #     Elf32_Off     e_phoff;
    #     Elf32_Off     e_shoff;
    #     Elf32_Word    e_flags;
    #     Elf32_Half    e_ehsize;
    #     Elf32_Half    e_phentsize;
    #     Elf32_Half    e_phnum;
    #     Elf32_Half    e_shentsize;
    #     Elf32_Half    e_shnum;
    #     Elf32_Half    e_shstrndx;
    #   } Elf32_Ehdr;
    #
    # ELF specification information:
    #
    #   http://www.skyfree.org/linux/references/ELF_Format.pdf
    class Reader
      attr_accessor :e_type, :e_machine, :e_version, :e_entry, :e_phoff, :e_shoff,
        :e_flags, :e_ehsize, :e_phentsize, :e_phnum, :e_shentsize, :e_shnum,
        :e_shstrndx, :raw_file, :sheaders

      def initialize elf_path
        File.open(elf_path, 'rb') { |elf_file| parse elf_file }
      end

      def parse elf_file
        # Read the whole file into memory for the sake of indexing into it later
        # if needs be.
        @raw_file = elf_file.read
        elf_file.rewind

        # Validate that the ELF magic number is present and correct.
        unless (magic_num = elf_file.read(4)) == "\x7fELF"
          raise "Not a valid ELF file! Magic number: " +
            "#{Utils.binary_str_to_bytes(magic_num)}"
        end

        @file_class = elf_file.read(1).bytes.first
        @data_enc   = elf_file.read(1).bytes.first
        @file_ver   = elf_file.read(1).bytes.first

        # Skip over the identifier padding. This may change in future versions of
        # the ELF specification as these bytes become used for other things.
        elf_file.read(9)

        # Read the rest of the ELF header. It looks a bit terrifying but it's just
        # reading bytes out of a file and interpreting them as numbers in a
        # correct way, as specified by the ELF standard.
        @e_type      = elf_file.read(ELF32_HALF_SIZE).unpack(ELF32_HALF).first
        @e_machine   = elf_file.read(ELF32_HALF_SIZE).unpack(ELF32_HALF).first
        @e_version   = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @e_entry     = elf_file.read(ELF32_ADDR_SIZE).unpack(ELF32_ADDR).first
        @e_phoff     = elf_file.read(ELF32_OFF_SIZE).unpack(ELF32_OFF).first
        @e_shoff     = elf_file.read(ELF32_OFF_SIZE).unpack(ELF32_OFF).first
        @e_flags     = elf_file.read(ELF32_WORD_SIZE).unpack(ELF32_WORD).first
        @e_ehsize    = elf_file.read(ELF32_HALF_SIZE).unpack(ELF32_HALF).first
        @e_phentsize = elf_file.read(ELF32_HALF_SIZE).unpack(ELF32_HALF).first
        @e_phnum     = elf_file.read(ELF32_HALF_SIZE).unpack(ELF32_HALF).first
        @e_shentsize = elf_file.read(ELF32_HALF_SIZE).unpack(ELF32_HALF).first
        @e_shnum     = elf_file.read(ELF32_HALF_SIZE).unpack(ELF32_HALF).first
        @e_shstrndx  = elf_file.read(ELF32_HALF_SIZE).unpack(ELF32_HALF).first

        # Seek to where the ELF headers have said that the section headers are.
        elf_file.seek(@e_shoff, IO::SEEK_SET)

        @sheaders = []
        @e_shnum.times do |i|
          @sheaders << SectionHeader.new(i, self, @e_shentsize, elf_file)
        end

      end

      def string_table
        @sheaders[@e_shstrndx]
      end
    end
  end
end
