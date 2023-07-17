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
        local data = {
            lock = true
        }
        rednet.broadcast(textutils.serializeJSON(data), "liftLock")
        print("Lift is locked")
    elseif args[1] == "unlock" then
        local data = {
            lock = false
        }
        rednet.broadcast(textutils.serializeJSON(data), "liftLock")
        print("Lift is unlocked")
    end
end
