local OTA = {}

function OTA.run(file)
    rednet.broadcast({
        ["file"] = file
    }, "ota_run")
end

function OTA.launch(path)
    rednet.broadcast({
        ["path"] = path
    }, "ota_launch")
end

function OTA.handle(parent, id, data, protocol)
    if protocol == "ota_run" then
        if data.file then
            pcall(shell.run, data.file)
            print("Run command [" .. data.file .. "]")
        else
            printError("Packet invalid")
        end
    elseif protocol == "ota_launch" then
        if data.path then
            local status, functions = pcall(require, data.path)
            if status then
                print("Running program")
                local status, value = pcall(parallel.waitForAny, parent, table.unpack(functions))
                if status then
                    print("Program finished")
                else
                    print(value)
                    print("OTA daemon still alive")
                end
            else
                printError("Failed to launch " .. data.path)
            end
        else
            printError("Packet invalid")
        end
    else
        return false
    end

    return true
end

return OTA
