#!/usr/bin/python
import json
from termcolor import colored
from subprocess import check_output
import sys

if len(sys.argv) != 2:
    print("Incorrect usage!")
    sys.exit(2)
logfile = sys.argv[1]

slotdict = {
    541213: "1:1", 541214: "1:2", 834239: "1:3", 834240: "1:4",
    541215: "2:1", 541216: "2:2", 541217: "2:3", 579927: "2:4",
    668840: "3:1", 668841: "3:2", 668842: "3:3", 668843: "3:4",
    668844: "4:1", 668845: "4:2", 668851: "4:3", 668852: "4:4"
}
slotcols = { "1": "red", "2": "blue", "3": "green", "4": "yellow" }

myname = "Ashish Kumar Yadav"
myid = 1685628
gsnm = check_output(["pass", "skedda/gs.nm"]).decode("utf-8").strip()
srnm = check_output(["pass", "skedda/sr.nm"]).decode("utf-8").strip()

starthr = 19

with open(logfile, 'r') as f:
    log = json.load(f)

usernames = [f'{x["firstName"]} {x["lastName"]}' for x in log["venueusers"]]
usernames.append(myname)
userids = [x["id"] for x in log["venueusers"]]
userids.append(myid)

bookings_s = []
bookings = []
for x in log["bookings"][1:]:
    time_r = x["start"]
    slot = slotdict[x["spaces"][0]]
    hr = int(time_r[11:13])
    if hr < starthr:
        continue
    time = f'{time_r[8:10]} {time_r[11:16]}'
    userid = x["venueuser"]
    idx = userids.index(userid)
    username = usernames[idx]
    bookings_s.append(f'{time} {slot} {username}')
    spc = '\t'
    colslot = colored(slot, slotcols[slot[0]], attrs=["bold"], force_color=True)
    if username == myname:
        colname = colored(username, "cyan", force_color=True)
    elif username == gsnm:
        colname = colored(username, "blue", force_color=True)
    elif username == srnm:
        colname = colored(username, "yellow", force_color=True)
    else:
        colname = username
    bookings.append(f'{spc*(hr-starthr)}{time} {colslot} {colname}')

bookings = [x for _, x in sorted(zip(bookings_s, bookings))]
for booking in bookings:
    print(booking)
