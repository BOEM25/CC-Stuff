args = {...}
utils = {} -- Table of utility functions

-- Link to json library to download if not downladed
jsonLibLink = "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua"


-- Table of gist id's for programs/scripts to download, 
-- make dynamic using webrequests???
files = {["miner"]="5fb47245f0861609b24d81f18b9ef569", ["farmer"]="4e39ce6ed3a884d999c5705adbf5c8bc", ["storage"]=nil, ["cs"]=nil, ["phone"]=nil, ["test"]=nil} -- yes, i know its possible without [""] but it looks cool oke ;)

-- Simple function to check if a value is in a table
function utils:checkInTable(set, key)
    for index, item in ipairs(set) do
        if item == key then
            return true
        end
    end
    return false
end

-- Simple function to check for a key in a table
function utils:checkInPairsTable(set, key)
    for index, item in pairs(set) do
        if index == key then
            return true
        end
    end
    return false
end

-- Simple function to (over)write a file 
function utils:writeToFile(file, data)
    local file = fs.open(file, "w")
    file.write(data)
    file.close()
    return true
end

-- Check if the json libary is downloaded, if so then check for updates, if not then download it
function utils:checkIfJsonExists()
    -- TODO: Make more dynamic if other libaries needed!
    -- Using a table and a for loop?

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

-- Function which takes in a gist id and downloads it
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

    for index, item in pairs(jData["files"]) do 
        print("Downloading "..item["filename"])
        content, reason = http.get(item["raw_url"])
        if content ~= nil then
            local data = {content = content.readAll(), size = item["size"], filename = item["filename"]}
            utils.writeToFile(self, data.filename, data.content)
            print("Downloaded "..data.filename..", size: "..data.size.."b")
        else
            error("Error getting gist! Reason: "..reason)
            return false
        end
    end
    
    return true
end

-- Load json libary with check if it exists
if utils.checkIfJsonExists() then
    json = require "json"
    if json == nil then -- not needed?
        error("Error occured during load of json")
    end
end

if utils.checkInPairsTable(self, files, args[1]) then
    id = files[args[1]]
    utils.downloadGistToFile(self, id)
else
    print("All files are: ??")
end