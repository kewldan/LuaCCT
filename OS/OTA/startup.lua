rednet.open("back")

local OTA = require("OTA")

print("OTA OS started")
function main()
    while true do
        local id, json, protocol = rednet.receive(nil, 5)
        if id ~= nil then
            OTA.handle(main, id, json, protocol)
        end
    end
end

main()
