rednet.open('back')

args = { ... }

local OTA = require("OTA")

if #args > 0 then
    local cmd = args[1]
    if cmd == "run" then
        if #args >= 2 then
            local c = ""
            for i = 2, #args, 1 do
                c = c .. args[i] .. " "
            end
            OTA.run(c:gsub("%s+", ""))
            print("Sent")
        end
    elseif cmd == "launch" then
        if #args >= 2 then
            local c = ""
            for i = 2, #args, 1 do
                c = c .. args[i] .. " "
            end
            OTA.launch(c:gsub("%s+", ""))
            print("Sent")
        end
    else
        printError("Unknown command")
    end
end
