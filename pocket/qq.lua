rednet.open('back')

args = {...}

local OTA = require("OTA")

if #args >= 2 then
    local group = args[1]
    local cmd = args[2]

    if cmd == "run" then
        if #args >= 3 then
            local c = ""
            for i = 3, #args, 1 do
                c = c .. args[i] .. " "
            end
            OTA.run(group, c:gsub("^%s*(.-)%s*$", "%1"))
            print("Sent to OTA." .. group .. " OTA_RUN packet")
        end
    elseif cmd == "launch" then
        if #args >= 3 then
            local c = ""
            for i = 3, #args, 1 do
                c = c .. args[i] .. " "
            end
            OTA.launch(group, c:gsub("^%s*(.-)%s*$", "%1"))
            print("Sent to OTA." .. group .. " OTA_LAUNCH packet")
        end
    elseif cmd == "group" then
        if #args == 3 then
            OTA.launch(group, args[3])
            print("Sent to OTA." .. group .. " OTA_GROUP packet")
        end
    else
        printError("Unknown command")
    end
end
