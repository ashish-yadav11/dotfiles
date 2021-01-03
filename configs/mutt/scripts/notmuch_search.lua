local argfile = "/tmp/neomutt/notmuch.arg"

-- read search term into arg and clear argfile
local f = io.open(argfile, "r")
if not f then return end
local arg = f:read("a")
f:close()
if arg == "" then return end
f = io.open(argfile, "w")
if not f then return end
f:close()

-- query notmuch
local o = io.popen("notmuch search --limit=500 --output=messages -- '" .. arg:gsub("'", "'\\''") .. "' 2>&1")
local output = o:read("a")

-- notmuch failed
if not o:close() then
    -- remove newline characters from the end
    output = output:gsub("\n*$", "")
    -- concatenate lines with '; '
    output = output:gsub("\n", "; ")

    mutt.error(output)
    return
end

-- process output
-- no matching messages
if output == "" then mutt.error("No messages matched criteria"); return end
-- escape ERE special tokens
output = output:gsub('([.%[\\()*+?{|^$])', '\\\\\\\\%1')
-- concatenate lines with |
output = output:gsub('\nid:', '|')
-- escape quotes
output = output:gsub('"', '\\\\\\"')
-- add ^<( at the start and )>$ at the end
output = output:gsub('^id:', '\\"^<(')
output = output:gsub('\n*$', ')>$\\"')
-- there shouldn't be any other newline characters in output
if output:find('\n') then mutt.error("notmuch output processing failed"); return end

-- call limit
mutt.command.push('"<limit>~i ' .. output .. '<Enter>"')
