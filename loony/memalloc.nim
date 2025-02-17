#
#
#            Nim's Runtime Library
#        (c) Copyright 2015 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

# Page size of the system; in most cases 4096 bytes. For exotic OS or
# CPU this needs to be changed:
const
  PageShift = when defined(cpu16): 8 else: 12 # \
    # my tests showed no improvements for using larger page sizes.
  PageSize = 1 shl PageShift
  PageMask = PageSize-1

  MemAlign = # also minimal allocatable memory block
    when defined(useMalloc):
      when defined(amd64): 16
      else: 8
    else: 16

  BitsPerPage = PageSize div MemAlign
  UnitsPerPage = BitsPerPage div (sizeof(int)*8)
    # how many ints do we need to describe a page:
    # on 32 bit systems this is only 16 (!)

  TrunkShift = 9
  BitsPerTrunk = 1 shl TrunkShift # needs to be power of 2 and divisible by 64
  TrunkMask = BitsPerTrunk - 1
  IntsPerTrunk = BitsPerTrunk div (sizeof(int)*8)
  IntShift = 5 + ord(sizeof(int) == 8) # 5 or 6, depending on int width
  IntMask = 1 shl IntShift - 1


when not defined(js):

  # Allocator statistics for memory leak tests

  {.push stackTrace: off.}


  template `+!`(p: pointer, s: SomeInteger): pointer =
    cast[pointer](cast[int](p) +% int(s))

  template `-!`(p: pointer, s: SomeInteger): pointer =
    cast[pointer](cast[int](p) -% int(s))

  proc allocAligned*(size, align: Natural): pointer =
    if align <= MemAlign:
      when compileOption("threads"):
        result = allocShared(size)
      else:
        result = alloc(size)
    else:
      # allocate (size + align - 1) necessary for alignment,
      # plus 2 bytes to store offset
      when compileOption("threads"):
        let base = allocShared(size + align - 1 + sizeof(uint16))
      else:
        let base = alloc(size + align - 1 + sizeof(uint16))
      # memory layout: padding + offset (2 bytes) + user_data
      # in order to deallocate: read offset at user_data - 2 bytes,
      # then deallocate user_data - offset
      let offset = align - (cast[int](base) and (align - 1))
      cast[ptr uint16](base +! (offset - sizeof(uint16)))[] = uint16(offset)
      result = base +! offset

  proc allocAligned0*(size, align: Natural): pointer =
    if align <= MemAlign:
      when compileOption("threads"):
        result = allocShared0(size)
      else:
        result = alloc0(size)
    else:
      # see comments for alignedAlloc
      when compileOption("threads"):
        let base = allocShared0(size + align - 1 + sizeof(uint16))
      else:
        let base = alloc0(size + align - 1 + sizeof(uint16))
      let offset = align - (cast[int](base) and (align - 1))
      cast[ptr uint16](base +! (offset - sizeof(uint16)))[] = uint16(offset)
      result = base +! offset

  proc deallocAligned*(p: pointer, align: int) {.compilerproc.} =
    if align <= MemAlign:
      when compileOption("threads"):
        deallocShared(p)
      else:
        dealloc(p)
    else:
      # read offset at p - 2 bytes, then deallocate (p - offset) pointer
      let offset = cast[ptr uint16](p -! sizeof(uint16))[]
      when compileOption("threads"):
        deallocShared(p -! offset)
      else:
        dealloc(p -! offset)

  {.pop.}
