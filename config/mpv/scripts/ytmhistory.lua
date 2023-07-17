local musicdir = "/media/storage/Music"

local function fileloaded()
    overthreshold = false
    fname = mp.get_property("filename", "")
end
--[[
local function eofreached(eof)
    os.execute("/home/ashish/.scripts/ytmsclu-history.sh '" .. fname:gsub("'", "'\\''") .. "'")
end
--]]
local function percentpos(_, perc)
    if not overthreshold then
        if perc and perc > 95 then
            overthreshold = true
            os.execute("/home/ashish/.scripts/ytmsclu-history.sh '" .. fname:gsub("'", "'\\''") .. "'")
        end
    else
        if perc and perc < 1 then
            overthreshold = false
        end
    end
end

local path = mp.get_property("path", "")
local wdir = mp.get_property("working-directory", "")
if (wdir .. path):sub(1, #musicdir) == musicdir then
    mp.register_event("file-loaded", fileloaded)
--[[
    mp.register_event("end-file", endfile)
--]]
    mp.observe_property("percent-pos", "number", percentpos)
end
