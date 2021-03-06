--simple virtual machine

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

-- reverse look up
local mnemonics = {
    "iadd", "isub", "imul", "ilt", "ieq", "br", "brt", "brf",
    "iconst", "load", "gload", "store", "gstore", "print", "pop",
    "halt", "call", "ret"
}

-- # of operands
local noperand = {
    [IADD] = 0,
    [ISUB] = 0,
    [IMUL] = 0,
    [ILT]  = 0,
    [IEQ]  = 0,
    [BR]   = 1, --jmp
    [BRT]  = 1,
    [BRF]  = 1,
    [ICONST] = 1,
    [LOAD]   = 1,
    [GLOAD]  = 1,
    [STORE]  = 1,
    [GSTORE] = 1,
    [PRINT] = 0,
    [POP]   = 0,
    [HALT]  = 0,
    [CALL]  = 2,
    [RET]   = 0,
}

local function VM(codedata, startaddress, datasize, trace)
    local vm = {}
    local code = codedata or {}
    local stack = {}
    local global = {}
    for i = 0, datasize - 1 do
        global[i] = 0
    end
    local sp = 0
    local fp = 0
    local ip = startaddress or 1

    local function operands(t, j)
        local opcount = noperand[t[j]] or datasize
        local result = "["
        for i = 1, opcount do
            result = result .. t[j+i] .. (i == opcount and "" or " ")
        end
        return result .. "]"
    end
    local function dumpstack()
        local res = {}
        for i = 1, sp do
            res[#res + 1] = stack[i]
        end
        return table.concat(res, ",")
    end
    local function printtrace()
        print(("%04d: %6s %11s Stack: %s"):format(ip, mnemonics[code[ip]], operands(code, ip), dumpstack()))
        --print(("Data %s"):format(operands(global, -1)))
    end

    function vm.execute()
        local opcode = code[ip]
        local halt = nil
        local err = nil
        while ip <= #code and not halt do
            if trace then printtrace() end
            ip = ip + 1
            if opcode == IADD then
                local b = stack[sp]
                sp = sp - 1
                local a = stack[sp]
                stack[sp] = a + b
            elseif opcode == ISUB then
                local b = stack[sp]
                sp = sp - 1
                local a = stack[sp]
                stack[sp] = a - b
            elseif opcode == IMUL then
                local b = stack[sp]
                sp = sp - 1
                local a = stack[sp]
                stack[sp] = a * b
            elseif opcode == ILT then
                local b = stack[sp]
                sp = sp - 1
                local a = stack[sp]
                stack[sp] = (a < b and 1 or 0)
            elseif opcode == IEQ then
                local b = stack[sp]
                sp = sp - 1
                local a = stack[sp]
                stack[sp] = (a == b and 1 or 0)
            elseif opcode == BR then
                ip = code[ip]
            elseif opcode == BRT then
                local addr = code[ip]
                ip = ip + 1
                if stack[sp] == 1 then
                    ip = addr
                end
                sp = sp - 1
            elseif opcode == BRF then
                local addr = code[ip]
                ip = ip + 1
                if stack[sp] == 0 then
                    ip = addr
                end
                sp = sp - 1
            elseif opcode == ICONST then
                sp = sp + 1
                stack[sp] = code[ip]
                ip = ip + 1
            elseif opcode == LOAD then
                local offset = code[ip]
                ip = ip + 1
                sp = sp + 1
                stack[sp] = stack[fp+offset]
            elseif opcode == GLOAD then
                sp = sp + 1
                stack[sp] = global[code[ip]]
                ip = ip + 1
            elseif opcode == STORE then
                local offset = code[ip]
                ip = ip + 1
                stack[fp+offset] = stack[sp]
                sp = sp - 1
            elseif opcode == GSTORE then
                global[code[ip]] = stack[sp]
                ip = ip + 1
                sp = sp - 1
            elseif opcode == PRINT then
                print(stack[sp])
                sp = sp - 1
            elseif opcode == POP then
                sp = sp - 1
            elseif opcode == HALT then
                halt = true
            elseif opcode == CALL then
                local addr = code[ip]
                ip = ip + 1
                local nargs = code[ip]
                ip = ip + 1
                sp = sp + 1
                stack[sp] = nargs
                sp = sp + 1
                stack[sp] = fp
                sp = sp + 1
                stack[sp] = ip
                fp = sp
                ip = addr
            elseif opcode == RET then
                local rval = stack[sp]
                sp = sp - 1
                sp = fp
                ip = stack[sp]
                sp = sp - 1
                fp = stack[sp]
                sp = sp - 1
                local nargs = stack[sp]
                sp = sp - nargs
                stack[sp] = rval
            end
            opcode = code[ip]
        end
        if halt == "error" then
            print(err)
        end
    end
    --disassemble program
    function vm.disassemble()
        local i = 0
        while i <= #code do
            local opcode = mnemonics[code[i]]
            if opcode then
                local nops = noperand[code[i]]
                for j=i+1, i+nops do
                    opcode = opcode .. ", " .. code[j]
                end
                print(i, opcode)
                i = i + nops
            end
            i=i+1
        end
    end

    return vm
end

return VM
