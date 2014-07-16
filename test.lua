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

local hello = {
    ICONST, 10,
    ICONST, 9,
    IADD,
    PRINT,
    HALT
}

local loop = {
    ICONST, 10,
    GSTORE, 0,
    ICONST, 0,
    GSTORE, 1,
    GLOAD, 1,
    GLOAD, 0,
    ILT,
    BRF, 25,
    GLOAD, 1,
    ICONST, 1,
    IADD,
    GSTORE, 1,
    BR, 9,
    GLOAD, 1,
    PRINT,
    HALT
}

local factorial = {
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

    ICONST, 10,
    CALL, 1, 1,
    PRINT,
    HALT
}

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

    ICONST, 10,
    GSTORE, 0,
    ICONST, 0,
    GSTORE, 1,

    GLOAD, 1,
    GLOAD, 0,
    ILT,
    BRF, 55,
    GLOAD, 1,
    ICONST, 1,
    IADD,
    GSTORE, 1,

    --print(fact(12))
    ICONST, 12,
    CALL, 1, 1,
    PRINT,

    BR, 31,
    GLOAD, 1,

    HALT
}

local vm = VM(hello, 1, 0, "trace")
vm.execute()

vm = VM(loop, 1, 2)
vm.execute()

vm = VM(factorial, 23, 0)
vm.execute()

vm = VM(loop_factorial, 23, 2)
vm.disassemble()
vm.execute()
