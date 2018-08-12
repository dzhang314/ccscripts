-- BTM: Better Turtle Movement
-- An improved turtle movement module for ComputerCraft 1.75.

if turtle.__btm_loaded__ then
    error("BTM has already been loaded.")
end

local BLOCK_LOG_FILE = assert(io.open("blocks.log", "a"))

turtle.__btm_loaded__ = true

-- Local constants for the zero vector and axis-aligned unit vectors.
local VEC_ZERO = vector.new(0, 0, 0)
local VEC_YPOS = vector.new(0, 1, 0)
local VEC_YNEG = vector.new(0, -1, 0)
local VEC_ZPOS = vector.new(0, 0, 1)

-- Coordinates are measured relative to the starting point of the turtle.
-- The turtle initially faces in the +Z direction, with the +X direction
-- to its right and the +Y direction pointing up.
local position = VEC_ZERO
local heading = VEC_ZPOS
local emptyPositions = {[tostring(position)] = true}

function getPosition()       return position       end
function getHeading()        return heading        end
function getEmptyPositions() return emptyPositions end

local turtle_up = turtle.up;                    turtle.up = nil
local turtle_down = turtle.down;                turtle.down = nil
local turtle_turnLeft = turtle.turnLeft;        turtle.turnLeft = nil
local turtle_turnRight = turtle.turnRight;      turtle.turnRight = nil
local turtle_forward = turtle.forward;          turtle.forward = nil
local turtle_back = turtle.back;                turtle.back = nil
                                                turtle.detect = nil
                                                turtle.detectUp = nil
                                                turtle.detectDown = nil
local turtle_inspect = turtle.inspect;          turtle.inspect = nil
local turtle_inspectUp = turtle.inspectUp;      turtle.inspectUp = nil
local turtle_inspectDown = turtle.inspectDown;  turtle.inspectDown = nil
local turtle_place = turtle.place;              turtle.place = nil
local turtle_placeUp = turtle.placeUp;          turtle.placeUp = nil
local turtle_placeDown = turtle.placeDown;      turtle.placeDown = nil
local turtle_dig = turtle.dig;                  turtle.dig = nil
local turtle_digUp = turtle.digUp;              turtle.digUp = nil
local turtle_digDown = turtle.digDown;          turtle.digDown = nil

--------------------------------------------------------------------------------

function moveForward()
    local success = turtle_forward()
    if success then
        position = position + heading
        emptyPositions[position] = true
    end
    return success
end

function moveBack()
    local success = turtle_back()
    if success then
        position = position - heading
        emptyPositions[position] = true
    end
    return success
end

function moveUp()
    local success = turtle_up()
    if success then
        position = position + VEC_YPOS
        emptyPositions[position] = true
    end
    return success
end

function moveDown()
    local success = turtle_down()
    if success then
        position = position + VEC_YNEG
        emptyPositions[position] = true
    end
    return success
end

--------------------------------------------------------------------------------

function turnLeft() -- Note: turning left cannot fail.
    heading = VEC_YNEG:cross(heading)
    return turtle_turnLeft()
end

function turnRight() -- Note: turning right cannot fail.
    heading = VEC_YPOS:cross(heading)
    return turtle_turnRight()
end

--------------------------------------------------------------------------------

local boringBlocks = {
    ["minecraft:dirt"] = true,
    ["minecraft:stone"] = true,
    ["minecraft:cobblestone"] = true,
    ["minecraft:gravel"] = true,
    ["minecraft:sand"] = true,

    ["minecraft:water"] = true,
    ["minecraft:flowing_water"] = true,
    ["minecraft:lava"] = true,
    ["minecraft:flowing_lava"] = true,

    ["minecraft:bedrock"] = true,

    ["minecraft:coal_ore"] = true,
    ["minecraft:iron_ore"] = true,
    ["minecraft:gold_ore"] = true,

    ["BigReactors:YelloriteOre"] = true,
    ["ProjRed|Exploration:projectred.exploration.ore"] = true,
    ["ThermalFoundation:Ore"] = true,

    ["minecraft:torch"] = true,
    ["minecraft:chest"] = true,
    ["IronChest:BlockIronChest"] = true,
}

function logBlockData(blockdata)
    if type(blockdata) ~= "table" then return end
    if type(blockdata.name) ~= "string" then return end
    if boringBlocks[blockdata.name] then return end
    BLOCK_LOG_FILE:write("Found block: <<" .. blockdata.name ..
                         ">> at position [[" .. tostring(position) .."]]\n")
    BLOCK_LOG_FILE:flush()
end

function lookForward()
    local success, blockdata = turtle_inspect()
    emptyPositions[tostring(position + heading)] = not success
    if success then logBlockData(blockdata) end
    return success, blockdata
end

function lookUp()
    local success, blockdata = turtle_inspectUp()
    emptyPositions[tostring(position + VEC_YPOS)] = not success
    if success then logBlockData(blockdata) end
    return success, blockdata
end

function lookDown()
    local success, blockdata = turtle_inspectDown()
    emptyPositions[tostring(position + VEC_YNEG)] = not success
    if success then logBlockData(blockdata) end
    return success, blockdata
end

--------------------------------------------------------------------------------

function placeForward()
    local success = turtle_place()
    emptyPositions[tostring(position + heading)] = not lookForward()
    return success
end

function placeUp()
    local success = turtle_placeUp()
    emptyPositions[tostring(position + VEC_YPOS)] = not lookUp()
    return success
end

function placeDown()
    local success = turtle_placeDown()
    emptyPositions[tostring(position + VEC_YNEG)] = not lookDown()
    return success
end

--------------------------------------------------------------------------------

function digForward()
    local success = turtle_dig()
    emptyPositions[tostring(position + heading)] = not lookForward()
    return success
end

function digUp()
    local success = turtle_digUp()
    emptyPositions[tostring(position + VEC_YPOS)] = not lookUp()
    return success
end

function digDown()
    local success = turtle_digDown()
    emptyPositions[tostring(position + VEC_YNEG)] = not lookDown()
    return success
end
