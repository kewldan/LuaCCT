local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")
if not rednet.isOpen() then
    rednet.open('back')
end

settings.define("floor", {
    description = "Elevator floor",
    default = nil,
    type = number
})

settings.load()

local yo = 1

local liftFloor = 0
local liftTarget = 0
local isCalling = false

monitor.setTextColor(colors.white)
monitor.setBackgroundColor(colors.green)
monitor.setTextScale(4)
monitor.clear()

local w, h = monitor.getSize()

function write(text, x, foreground, background)
    while #text < w do
        text = text .. " "
    end
    monitor.setCursorPos(x, yo)
    yo = yo + 1
    monitor.setTextColor(foreground)
    monitor.setBackgroundColor(background)
    monitor.write(text)
end

function t(s, a, b)
    if s then
        return a
    else
        return b
    end
end

function on_launch()
    local text = "Welcome"
    monitor.setCursorPos(1, 1)
    monitor.setTextColor(colors.white)
    monitor.setBackgroundColor(colors.black)
    for i = 1, #text do
        monitor.setCursorPos(1, 1)
        if i + 1 > #text then
            monitor.write(text:sub(i, i) .. " ")
        else
            monitor.write(text:sub(i, i) .. text:sub(i + 1, i + 1))
        end
        os.sleep(0.2)
    end
end

function main()
    on_launch()
    if settings.get('floor') then
        print("Configurated floor is " .. tostring(settings.get('floor')))
        speaker.playSound("entity.player.levelup", 3)
    end
    print("Lift slave started")
    while true do
        yo = 1
        if liftFloor == settings.get('floor') and liftTarget == liftFloor then
            if color ~= colors.green then
                speaker.playSound("entity.experience_orb.pickup", 3, 1)
            end
            color = colors.green
        elseif isCalling then
            color = colors.orange
        else
            color = colors.black
        end
        write(("%02d"):format(liftFloor), 1, colors.white, color)
        os.sleep(0.5)
    end
end

function touchEvent()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        if not isCalling then
            speaker.playSound("entity.experience_orb.pickup", 3, 0.5)
            local data = {
                ["floor"] = settings.get('floor')
            }
            rednet.broadcast(textutils.serializeJSON(data), 'liftCall')
        end
    end
end

function modemEvent()
    while true do
        local id, json, protocol = rednet.receive(nil, 5)
        if id then
            if protocol == 'liftTick' then
                local data = textutils.unserializeJSON(json)
                liftFloor = data['floor']
                liftTarget = data['target']
                isCalling = false
                for i, v in ipairs(data['path']) do
                    if v == settings.get('floor') then
                        isCalling = true
                    end
                end
            elseif protocol == 'callFloor' then
                local data = textutils.unserializeJSON(json)
                isCalling = data['target'] == settings.get('floor')
            end
        end
    end
end

function inputLoop()
    while true do
        settings.set("floor", tonumber(read()))
        settings.save()
        print("Floor set as " .. tostring(settings.get("floor")))
    end
end

return {main, touchEvent, modemEvent, inputLoop}
