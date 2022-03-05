#!/usr/bin/python

import re
import sys
import subprocess

remote = 'gdrive-iiser:'

def getid(source):
    idpatterns = [
        re.compile('/file/d/([0-9A-Za-z_-]{10,})(?:/|$)', re.IGNORECASE),
        re.compile('/folders/([0-9A-Za-z_-]{10,})(?:/|$)', re.IGNORECASE),
        re.compile('id=([0-9A-Za-z_-]{10,})(?:&|$)', re.IGNORECASE),
        re.compile('([0-9A-Za-z_-]{10,})', re.IGNORECASE)
    ]

    for pattern in idpatterns:
        match = pattern.search(source)
        if match:
            return match.group(1)

    print(f"Error: unable to get ID from {source}")
    sys.exit(1)

def dieusage():
    print("Usage: gdown source-url|source-id [target]")
    sys.exit(1)

if __name__ == '__main__':
    argc = len(sys.argv)
    if argc < 2 or argc > 3:
        dieusage()
    sourceid = getid(sys.argv[1])
    target = sys.argv[2] if argc > 2 else './'
    subprocess.run(
        ['rclone', '--progress', 'backend', 'copyid', remote, sourceid, target]
    )
