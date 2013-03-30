module Assam
  module ELF
    # ELF Data types (correspond to value to send to #pack and #unpack). They
    # all follow native system endianness, as per the ELF spec.
    ELF32_ADDR         = "L" # 4 bytes, unsigned
    ELF32_HALF         = "S" # 2 bytes, unsigned
    ELF32_OFF          = "L" # 4 bytes, unsigned
    ELF32_SWORD        = "l" # 4 bytes, signed
    ELF32_WORD         = "L" # 4 bytes, unsigned
    UNSIGNED_CHAR      = "C" # 1 byte, unsigned
    ELF32_ADDR_SIZE    = 4
    ELF32_HALF_SIZE    = 2
    ELF32_OFF_SIZE     = 4
    ELF32_SWORD_SIZE   = 4
    ELF32_WORD_SIZE    = 4
    UNSIGNED_CHAR_SIZE = 1

    # EI_CLASS constants.
    ELFCLASSNONE = 0
    ELFCLASS32   = 1
    ELFCLASS64   = 2

    # EI_DATA constants
    ELFDATANONE = 0
    ELFDATA2LSB = 1
    ELFDATA2MSB = 2

    # EI_VERSION constants
    EV_NONE    = 0
    EV_CURRENT = 1

    # e_machine constants
    EM_NONE  = 0 # No machine
    EM_M32   = 1 # AT&T WE 32100
    EM_SPARC = 2 # SPARC
    EM_386   = 3 # Intel 80386
    EM_68K   = 4 # Motorola 68000
    EM_88K   = 5 # Motorola 88000
    EM_860   = 7 # Intel 80860
    EM_MIPS  = 8 # MIPS RS3000

    # Section header constants
    SHN_UNDEF     = 0
    SHN_LORESERVE = 0xff00
    SHN_LOPROC    = 0xff00
    SHN_HIPROC    = 0xff1f
    SHN_ABS       = 0xfff1
    SHN_COMMON    = 0xfff2
    SHN_HIRESERVE = 0xffff

    # Section header table constants
    SHT_NULL     = 0
    SHT_PROGBITS = 1
    SHT_SYMTAB   = 2
    SHT_STRTAB   = 3
    SHT_RELA     = 4
    SHT_HASH     = 5
    SHT_DYNAMIC  = 6
    SHT_NOTE     = 7
    SHT_NOBITS   = 8
    SHT_REL      = 9
    SHT_SHLIB    = 10
    SHT_DYNSYM   = 11
    SHT_LOPROC   = 0x70000000
    SHT_HIPROC   = 0x7fffffff
    SHT_LOUSER   = 0x80000000
    SHT_HIUSER   = 0xffffffff

    # Section header flag constants
    SHF_WRITE     = 0x1
    SHF_ALLOC     = 0x2
    SHF_EXECINSTR = 0x4
    SHF_MASKPROC  = 0xf0000000
  end
end
