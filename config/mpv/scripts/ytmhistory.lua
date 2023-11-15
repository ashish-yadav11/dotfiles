local musicdir = "/media/storage/Music"

local function fileloaded()
    overthreshold = false
    filepath = mp.get_property("path", "")
end
--[[
local function eofreached(eof)
    os.execute("/home/ashish/.scripts/ytmsclu-history.sh '" .. filepath:gsub("'", "'\\''") .. "'")
end
--]]
local function percentpos(_, perc)
    if not overthreshold then
        if perc and perc > 95 then
            overthreshold = true
            os.execute("/home/ashish/.scripts/ytmsclu-history.sh '" .. filepath:gsub("'", "'\\''") .. "'")
        end
    else
        if perc and perc < 1 then
            overthreshold = false
        end
    end
end

local wdir = mp.get_property("working-directory", "")
if wdir:sub(1, #musicdir) == musicdir then
    mp.register_event("file-loaded", fileloaded)
--[[
    mp.register_event("end-file", eofreached)
--]]
    mp.observe_property("percent-pos", "number", percentpos)
end
