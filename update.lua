args = {...}
utils = {}

jsonLibLink = "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua"
files = {["miner"]=nil, ["farmer"]=nil, ["storage"]=nil, ["cs"]=nil, ["phone"]=nil, ["test"]=nil} -- yes, i know its possible without [""] but it looks cool oke ;)

function utils:checkInTable(set, key)
    for index, item in ipairs() do
        if item == key then
            return true
        end
    end
    return false
end

function utils:checkInPairsTable(set, key)
    for index, item in pairs() do
        if index == key then
            return true
        end
    end
    return false
end

function utils:writeToFile(file, data)
    file = fs.open(file, "w")
    file.write(data)
    file.close()
    return true
end

function utils:checkIfJsonExists()
    -- TODO: Make more dynamic if other libaries needed!

    if fs.exists("json.lua") then -- If json lib already exists
        print("Json Exists")

        -- Check for updates
        print("Checking for updates for Json Library...")
        response = http.get(jsonLibLink)

        if response ~= nil then -- request succesfull
            data = response.readAll() -- Can only read once otherwise?
            file = fs.open("json.lua", "r")
            if file.readAll() ~= data then
                file.close()
                utils.writeToFile("json.lua", data)
                print("Updated!")
            else
                print("All up to date!")
            end
        else
            print("Request failed, internet down?")
        end
    else
        print("Json does not exists")
        print("Downloading json...")
        response = http.get(jsonLibLink) -- request and get file

        if response ~= nil then -- Request succesfull
            file = fs.open("json.lua", "w") -- Create file
            file.write(response.readAll()) -- Write raw data
            file.close() -- Close
            print("Download succesfull! Json installed!")

        else
            print("Request failed, internet down?")
            return false
        end
    end
    return true
end

if utils.checkIfJsonExists() then
    json = require "json"
    if json == nil then
        error("Error occured during load of json")
end