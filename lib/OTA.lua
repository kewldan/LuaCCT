local OTA = {}

function OTA.run(group, file)
    rednet.broadcast({
        group = group,
        file = file
    }, "ota_run")
end

function OTA.launch(group, path)
    rednet.broadcast({
        group = group,
        path = path
    }, "ota_launch")
end

function OTA.group(group, ngroup)
    rednet.broadcast({
        group = group,
        ngroup = ngroup
    }, "ota_group")
end

function OTA.handle(parent, id, data, protocol, group)
    if protocol == "ota_run" then
        if data.file and data.group then
            if data.group ~= group then
                return true
            end

            pcall(shell.run, data.file)
            print("[OTA] Run command [" .. data.file .. "]")
        else
            printError("[OTA] Packet invalid")
        end
    elseif protocol == "ota_launch" then
        if data.path and data.group then
            if data.group ~= group then
                return true
            end

            local status, functions = pcall(require, data.path)
            if status then
                print("[OTA] Running program")
                local status, value = pcall(parallel.waitForAny, parent, table.unpack(functions))
                if status then
                    print("[OTA] Program finished")
                else
                    print(value)
                    print("[OTA] OTA daemon still alive")
                end
            else
                printError("[OTA] Failed to launch " .. data.path)
            end
        else
            printError("[OTA] Packet invalid")
        end
    elseif protocol == "ota_group" then
        if data.group and data.ngroup then
            if data.group == group then
                settings.set("ota.group", data.ngroup)
                settings.save()
                print("[OTA] Group updated to " .. data.ngroup)
            end
        else
            printError("[OTA] Packet invalid")
        end
    else
        return false
    end

    return true
end

return OTA
