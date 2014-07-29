define erase-all
  dont-repeat
  mon halt
  set {int} 0x4001e504 = 2
  set {int} 0x4001e50c = 1
  set {int} 0x40010514 = 1
  mon reset
end

# Usage: flash <program.elf>
define flash
  dont-repeat
  mon halt
  shell sleep 1
  file $arg0
  load
  # set {int} 0x10001014 = __Vectors # TODO TEST !
  mon reset
  mon go
end

# Usage: flash-all <softdevice.elf> <program.elf>
define flash-all
  dont-repeat
  erase-all
  shell sleep 1
  file $arg0
  load
  file $arg1
  load
  set {int} 0x10001014 = __Vectors
  mon reset
  mon go
end

define enter-dfu
  mon halt
  set {int} 0x20003c7c = 0xBeefFace
  mon reset
  mon go
end
