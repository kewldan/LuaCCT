rednet.open("back")

args = {...}

if #args >= 1 then
    if args[1] == "go" then
        if #args == 2 then
            local status, floor = pcall(tonumber, args[2])
            if status then
                local data = {
                    ["floor"] = floor
                }

                rednet.broadcast(textutils.serializeJSON(data), "liftCall")
                print("Calling to " .. args[2])
            end
        end
    elseif args[1] == "lock" then
        if #args == 2 then
            local data = {
                ["lock"] = args[2] == "true"
            }
            rednet.broadcast(textutils.serializeJSON(data), "liftLock")
            if args[2] == "true" then
                print("Lift is locked")
            else
                print("Lift is unlocked")
            end
        end
    end
end
