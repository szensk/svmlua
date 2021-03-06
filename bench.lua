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

local loop_factorial = {
    LOAD, -3,
    ICONST, 2,
    ILT,
    BRF, 11,
    ICONST, 1,
    RET,

    LOAD, -3,
    LOAD, -3,
    ICONST, 1,
    ISUB,
    CALL, 1, 1,
    IMUL,
    RET,

    ICONST, 1000000, --23
    GSTORE, 0,  --25
    ICONST, 0,  --27
    GSTORE, 1,  --29

    GLOAD, 1,   --31
    GLOAD, 0,   --33
    ILT,        --34
    BRF, 55,    --35
    GLOAD, 1,   --37
    ICONST, 1,  --39
    IADD,       --40
    GSTORE, 1,  --42

    --call fact
    ICONST, 12, --44
    CALL, 1, 1, --46
    POP, -- 49

    BR, 31, --50
    GLOAD, 1, --52

    HALT --54
}

local vm = VM(loop_factorial, 23, 2)
vm.execute()
