#!/usr/bin/python
import json
from termcolor import colored
from subprocess import check_output
import os.path
import sys

histfile=""
if len(sys.argv) == 2:
    logfile = sys.argv[1]
elif len(sys.argv) == 3:
    logfile = sys.argv[1]
    histfile = sys.argv[2]
else:
    print("Incorrect usage!")
    sys.exit(2)

slotdict = {
    541213: "1:1", 541214: "1:2", 834239: "1:3", 834240: "1:4",
    541215: "2:1", 541216: "2:2", 541217: "2:3", 579927: "2:4",
    668840: "3:1", 668841: "3:2", 668842: "3:3", 668843: "3:4",
    668844: "4:1", 668845: "4:2", 668851: "4:3", 668852: "4:4"
}
slotcols = { "1": "yellow", "2": "red", "3": "blue", "4": "green" }

myname = "Ashish Kumar Yadav"
myid = 1685628
#gsnm = check_output(["pass", "skedda/gs.nm"]).decode("utf-8").strip()
srnm = check_output(["pass", "skedda/sr.nm"]).decode("utf-8").strip()

starthr = 18

with open(logfile, 'r') as f:
    log = json.load(f)

usernames = [f'{x["firstName"].strip()} {x["lastName"].strip()}' for x in log["venueusers"]]
usernames.append(myname)
userids = [int(x["id"]) for x in log["venueusers"]]
userids.append(myid)

pbookings_s = []
if histfile and os.path.isfile(histfile):
    with open(histfile, 'r') as f:
        pbookings_s = json.load(f)

bookings_s = []
bookings = []
for x in log["bookings"]:
    time_r = x["start"]
    slot = slotdict[int(x["spaces"][0])]
    hr = int(time_r[11:13])
    if hr < starthr:
        continue
    if x["venueuser"]:
        userid = int(x["venueuser"])
    else:
        continue
    idx = int(userids.index(userid))
    username = usernames[idx]
    booking_s = f'{time_r} {slot} {username}'
    bookings_s.append(booking_s)
    spc = '\t'
    time = f'{time_r[8:10]} {time_r[11:16]}'
    colslot = colored(slot, slotcols[slot[0]], attrs=["bold"], force_color=True)
    if username == myname:
        colname = colored(username, "cyan", force_color=True)
#   elif username == gsnm:
#       colname = colored(username, "blue", force_color=True)
    elif username == srnm:
        colname = colored(username, "yellow", force_color=True)
    else:
        colname = username
    if pbookings_s and booking_s not in pbookings_s:
        bookings.append(f'{spc*(hr-starthr)}{time} {colslot} {colname}*')
    else:
        bookings.append(f'{spc*(hr-starthr)}{time} {colslot} {colname}')

bookings = [x for _, x in sorted(zip(bookings_s, bookings))]
for booking in bookings:
    print(booking)

if histfile:
    with open(histfile, 'w') as f:
        json.dump(bookings_s, f)
