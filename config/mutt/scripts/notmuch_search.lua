local argfile = "/tmp/neomutt/notmuch.arg"
local outfile = "/tmp/neomutt/notmuch.out"

-- read search term from argfile into arg and clear argfile
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

-- no matching messages
if output == "" then mutt.error("No messages matched criteria"); return end
-- add < at the start
output = output:gsub("^id:", "<")
-- add > at the end removing the newline character
output = output:gsub("\n$", ">")
-- remove 'id:' from the beginning of each line
output = output:gsub("\nid:", ">\n<")

-- write output to outfile
local f = io.open(outfile, "w")
if not f then return end
f:write(output)
f:close()

-- set external_search_command to cat outfile and call limit with dummy parameter
mutt.command.push([["<enter-command>set my_external_search_command=\$external_search_command external_search_command='cat ]] .. outfile .. [[; :'<Enter><limit>~I x<Enter><refresh><enter-command>set external_search_command=\$my_external_search_command; unset my_external_search_command<Enter>"]])
