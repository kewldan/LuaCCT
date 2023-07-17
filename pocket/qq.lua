rednet.open('back')

args = { ... }

local OTA = require("OTA")

if #args > 0 then
    local cmd = args[1]
    if #args >= 2 then
        local group = args[2]
        if cmd == "run" then
            if #args >= 3 then
                local c = ""
                for i = 3, #args, 1 do
                    c = c .. args[i] .. " "
                end
                OTA.run(group, c:gsub("^%s*(.-)%s*$", "%1"))
                print("Sent")
            end
        elseif cmd == "launch" then
            if #args >= 3 then
                local c = ""
                for i = 3, #args, 1 do
                    c = c .. args[i] .. " "
                end
                OTA.launch(group, c:gsub("^%s*(.-)%s*$", "%1"))
                print("Sent")
            end
        else
            printError("Unknown command")
        end
    end
    
end
