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
    local file = fs.open(file, "w")
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
        local response = http.get(jsonLibLink)

        if response ~= nil then -- request succesfull
            local data = response.readAll() -- Can only read once otherwise?
            local file = fs.open("json.lua", "r")
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
        local response = http.get(jsonLibLink) -- request and get file

        if response ~= nil then -- Request succesfull
            local file = fs.open("json.lua", "w") -- Create file
            file.write(response.readAll()) -- Write raw data
            file.close() -- Close
            print("Download succesfull, Json installed!")

        else
            print("Request failed, internet down?")
            return false
        end
    end
    return true
end

function utils:downloadGistToFile(gistID)
    if gistID == nil then
        return false
    end
    print("Requesting gist..")
    local link = "https://api.github.com/gists/"..gistID
    local response = http.get(link)
    if response ~= nil then
        jData = json.decode(response.readAll())
    else
        return false
    end

    -- want to get the first item in the files list, probably a better way to do but hey, it works :)
    numberIndex = 1
    for index, item in pairs(jData["files"]) do
        if numberIndex == 1 then
            content, reason = http.get(item["raw_url"])
            if content ~= nil then
                local data = {content = content.readAll(), size = item["size"], filename = item["filename"]}
                utils.writeToFile(self, data.filename, data.content)
                print("Downloaded "..data.filename..", size: "..data.size.."b")
                return true
            else
                error("Error getting gist! Reason: "..reason)
                return false
            end
        end
        numberIndex = numberIndex + 1
    end
end

if utils.checkIfJsonExists() then
    json = require "json"
    if json == nil then
        error("Error occured during load of json")
    end
end


id = "bcf3970b2edb26aa234463fca70f3d94"
print(utils.downloadGistToFile(self, id))