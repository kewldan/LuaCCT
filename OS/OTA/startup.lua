rednet.open("back")

local OTA = require("OTA")

settings.define("ota.group", {
    description = "Ota group filter",
    default = "default",
    type = string
})

settings.load()

local pressed = false

function BIOS()
    while true do
        local _, character = os.pullEvent("char")
        print(character)
        if character == 'f' then
            print("Enter group override (" .. settings.get("ota.group") .. "):")
            write("> ")
            local group = read()
            settings.set("ota.group", group)
            settings.save()
        end
    end
end

parallel.waitForAny(BIOS, function()
    os.sleep(3)
    if pressed then
        while true do
            os.sleep(30)
        end
    end
end)

print("OTA OS started")
function main()
    while true do
        local id, json, protocol = rednet.receive(nil, 5)
        if id ~= nil then
            OTA.handle(main, id, json, protocol, settings.get("ota.group"))
        end
    end
end

main()
