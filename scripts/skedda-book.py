#!/usr/bin/python
import json
import datetime as dt
from subprocess import check_output
import sys

loginfile = "/home/ashish/.config/skedda/booking.json"

def usageexit():
    print("Incorrect usage!")
    sys.exit(2)

if len(sys.argv) != 3:
    usageexit()
slot = sys.argv[1]
if len(slot) != 3 or slot[0] not in "1234" or slot[1] != ':' or slot[2] not in "1234":
    usageexit()
time = sys.argv[2]
if len(time) != 2 or time[1] not in "789":
    usageexit()
t = dt.datetime.now().replace(hour=12+int(time[1]),minute=0,second=0,microsecond=0)
if t < dt.datetime.now():
    t += dt.timedelta(days=1)
if time[0] == ',':
    pass
elif time[0] == '.':
    t += dt.timedelta(days=1)
elif time[0] == '/':
    t += dt.timedelta(days=2)
else:
    usageexit()
timestart = t.strftime("%Y-%m-%dT%H:%M:%S")
t += dt.timedelta(hours=1)
timeend = t.strftime("%Y-%m-%dT%H:%M:%S")

mobnum = check_output(["pass", "mobnum"]).decode("utf-8").strip()

slotdict = {
    "1:1": 541213, "1:2": 541214, "1:3": 834239, "1:4": 834240,
    "2:1": 541215, "2:2": 541216, "2:3": 541217, "2:4": 579927,
    "3:1": 668840, "3:2": 668841, "3:3": 668842, "3:4": 668843,
    "4:1": 668844, "4:2": 668845, "4:3": 668851, "4:4": 668852
}

with open(loginfile, 'r') as f:
    data = json.load(f)
data["booking"]["spaces"][0] = slotdict[slot]
data["booking"]["start"] = timestart
data["booking"]["end"] = timeend
data["booking"]["customFields"][0]["value"] = int(mobnum)
print(json.dumps(data, indent=4))
