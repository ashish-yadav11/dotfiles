local musicdir = "/media/storage/Music"
local archive = musicdir .. "/archive/"

local function fileloaded()
    local filepath = mp.get_property("path", "")
    if filepath:sub(1, #archive) == archive then
        os.execute("notify-send -h int:transient:1 -t 1500 mpv 'playing from the archive!'")
    end
end

local wdir = mp.get_property("working-directory", "")
if wdir == musicdir then
    mp.register_event("file-loaded", fileloaded)
end
