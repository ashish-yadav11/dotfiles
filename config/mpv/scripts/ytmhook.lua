local musicdir = "/media/storage/Music"

function endfile(event)
    if event["reason"] == "eof" then
        local fname = mp.get_property("filename", "")
        os.execute("/home/ashish/.scripts/ytmsclu-history.sh '" .. fname:gsub("'", "'\\''") .. "'")
    end
end

local path = mp.get_property("path", "")
local wdir = mp.get_property("working-directory", "")
local fullpath = wdir .. path
if fullpath:sub(1, #musicdir) then
    mp.register_event("end-file", endfile)
end
