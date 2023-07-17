local da = peripheral.wrap("back")
local side = "east"
local motor = peripheral.wrap("electric_motor_1")
local path = {}

rednet.open('bottom')
local computers = {}
local heights = {113, 106, 99, 87, 75, 68, 61, 54, 42, 35, 28, 21, 14, 3}
local locked = false

string.startswith = function(self, str)
    return self:find('^' .. str) ~= nil
end

string.split = function(self, pat)
    local p = {}
    for w in self:gmatch(pat) do
        table.insert(p, w)
    end
    return p
end

local e_goto = function(floor)
    da.gotoElevatorFloor(side, floor)
end

local floors = da.getElevatorFloors(side)
print("Detected " .. tostring(floors) .. " floors")

function onCall(callFloor)
    if not locked then
        table.insert(path, callFloor)
    end
end

function determineCurrentFloor()
    if #heights == floors then
        for i = 1, #heights, 1 do
            if da.getPulleyDistance(side) >= heights[i] then
                return i - 1
            end
        end
    end
    return 911
end

function broadcastLiftFloor()
    local f = determineCurrentFloor()
    if locked then
        f = 99
    end
    local data = {
        ["floor"] = f,
        ["target"] = da.getElevatorFloor(side),
        ["path"] = path
    }
    rednet.broadcast(textutils.serializeJSON(data), 'liftTick')
end

function main()
    if #heights ~= floors then
        heights = {}
        print("Calibration...")
        local currentLength = da.getPulleyDistance(side)
        for i = 1, floors, 1 do
            local delta = da.gotoElevatorFloor(side, i - 1)
            da.gotoElevatorFloor(side, floors - 1)
            table.insert(heights, currentLength + math.abs(delta))
            print("For floor " .. tostring(i - 1) .. " pulley distance is " .. tostring(currentLength + math.abs(delta)))
        end
    end

    print("Lift master started")
end

function packetLoop()
    while true do
        local id, json, protocol = rednet.receive(nil, 5)
        if id ~= nil then
            if protocol == 'liftCall' then
                local data = textutils.unserializeJSON(json)
                onCall(data['floor'])
            elseif protocol == "liftLock" then
                local data = textutils.unserializeJSON(json)
                if data["lock"] then
                    motor.stop()
                else
                    motor.setSpeed(32)
                end
                locked = data["lock"]
            end
        end
    end
end

function broadcastLoop()
    while true do
        broadcastLiftFloor()
        os.sleep(0.1)
    end
end

function pathSolver()
    while true do
        if #path > 0 then
            if determineCurrentFloor() ~= path[1] then
                e_goto(path[1])
                os.sleep(1)
            else
                table.remove(path, 1)
            end
        end
        os.sleep(0.2)
    end
end

parallel.waitForAll(main, packetLoop, broadcastLoop, pathSolver)
