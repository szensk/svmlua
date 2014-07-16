--test
local VM = require 'vm'

--mnemonics for byte codes
local IADD = 1
local ISUB = 2
local IMUL = 3
local ILT  = 4
local IEQ  = 5
local BR   = 6 --jmp
local BRT  = 7
local BRF  = 8
local ICONST = 9
local LOAD   = 10
local GLOAD  = 11
local STORE  = 12
local GSTORE = 13
local PRINT  = 14
local POP  = 15
local HALT = 16
local CALL = 17
local RET  = 18
local IKGSTR = 19
local LOAD2  = 20
local GLOAD2 = 21
local ILTBRF = 22
local IKADD  = 23
local IKSUB  = 24
local IKCALL = 25

local loops = 1000000
local loop_factorial = {
    LOAD, -3,
    ICONST, 2,
    ILTBRF, 10,
    ICONST, 1,
    RET,

    LOAD2, -3, -3,
    IKSUB, 1,
    CALL, 1, 1,
    IMUL,
    RET,

    --loop start
    IKGSTR, loops, 0, --23
    IKGSTR, 0, 1,  --27

    GLOAD2, 1, 0,   --31  --33
    ILTBRF, 46,       --34
    GLOAD, 1,   --37
    IKADD, 1,  --39       --40
    GSTORE, 1,  --42

    --call fact
    IKCALL, 12, 1, 1, --46
    POP,

    --jump to gload2
    BR, 26,
    GLOAD, 1,

    --bail
    HALT
}

print(#loop_factorial * 4, 'bytes')
local vm = VM(loop_factorial, 20, 2)
--vm.disassemble()
vm.execute()
