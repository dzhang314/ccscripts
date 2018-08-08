local CONSOLE_LOG_FILENAME = "console.log"
local CONSOLE_LOG_FILE = assert(io.open(CONSOLE_LOG_FILENAME, "a"))
local INDENT_STRING = "    "

local function toTypedString(obj)
    if type(obj) == "function" then
        local str = tostring(obj)
        if string.sub(str, 1, 10) == "function: " then
            return "[function " .. string.sub(str, 11, -1) .. "]"
        end
    end
    return type(obj) .. ": [[" .. tostring(obj) .. "]]"
end

local function logWrite(str, indentLevel)
    if type(str) ~= "string" then
        error("console.logWrite received bad parameter: " ..
              "expected string, got " .. type(str), 2)
    end
    if type(indentLevel) ~= "number" then
        error("console.logWrite received bad parameter: " ..
              "expected number, got " .. type(indentLevel), 2)
    end
    if not (indentLevel >= 0 and indentLevel == math.floor(indentLevel)) then
        error("console.logWrite received bad parameter: " ..
              "indentLevel must be a non-negative integer", 2)
    end
    for _ = 1, indentLevel do CONSOLE_LOG_FILE:write(INDENT_STRING) end
    CONSOLE_LOG_FILE:write(str)
    CONSOLE_LOG_FILE:write('\n')
    CONSOLE_LOG_FILE:flush()
end

local function logPair(key, value, indentLevel)
    logWrite("<< " .. toTypedString(key) ..
             " :: " .. toTypedString(value) .. " >>", indentLevel)
end

local function logObject(object, indentLevel)
    if type(object) == "table" then
        logWrite("contents of " .. toTypedString(object) .. ":", indentLevel)
        for key, value in pairs(object) do
            logPair(key, value, indentLevel + 1)
        end
    elseif type(object) == "string" or type(object) == "number"
            or type(object) == "function" or type(object) == "nil" then
        logWrite(toTypedString(object), indentLevel)
    else
        logWrite("object of unknown type " .. toTypedString(object),
                 indentLevel)
    end
end

function log(object) logObject(object, 0) end

function logAdvancedMethodsData(api)
    local data = api.getAdvancedMethodsData()
    if type(data) ~= "table" then
        logWrite("ERROR: Failed to retrieve advanced methods data.", 2)
        return
    end
    for name, info in pairs(data) do
        if type(name) == "string" and type(info) == "table" then
            if name ~= "listMethods" and name ~= "listSources" and
                    name ~= "getAdvancedMethodsData" then
                local argNames = {}
                for i, arg in ipairs(info.args) do
                    argNames[i] = arg.optional and ('[' .. arg.name .. ']')
                                               or arg.name
                end
                logWrite(name .. string.sub(api.doc(name), 9, -1), 2)
                logWrite("Source: " .. info.source, 3)
                for _, arg in ipairs(info.args) do
                    logWrite(arg.name .. ": " .. arg.description, 3)
                end
            end
        else
            logWrite("Unexpected advanced methods data entry:", 2)
            logPair(name, info, 3)
        end
    end
end

function peripheralReport()
    logWrite("=========================== BEGIN PERIPHERAL REPORT " ..
             "===========================", 0)

    for _, side in ipairs(peripheral.getNames()) do
        logWrite("Peripheral on side \"" .. side ..
                 "\" of type \"" .. peripheral.getType(side) .. "\":", 0)
        local peripheralAPI = peripheral.wrap(side)
        if type(peripheralAPI) ~= "table" then
            logWrite("ERROR: Failed to load API for this peripheral.", 1)
        else
            local isOpenPeripheral =
                    type(peripheralAPI.getAdvancedMethodsData) == "function"
            if isOpenPeripheral then
                logWrite("Is an OpenPeripheral. Advanced methods data:", 1)
                logAdvancedMethodsData(peripheralAPI)
            else
                logWrite("Not an OpenPeripheral.", 1)
                logWrite("Available methods:", 1)
                for name, method in pairs(peripheralAPI) do
                    if type(name) == "string" and
                            type(method) == "function" then
                        logWrite(name, 2)
                    else
                        logWrite("Unexpected peripheral API entry:", 2)
                        logPair(name, method, 3)
                    end
                end
            end
        end
    end

    logWrite("============================ END PERIPHERAL REPORT " ..
             "============================", 0)
end
