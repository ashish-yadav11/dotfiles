#!/usr/bin/python

import urllib.request
import json
import urllib
from pprint import pprint
import sys

if (len(sys.argv) != 2):
    print("Error: incorrect usage!")
    sys.exit(1)

ytid = sys.argv[1]

params = {"format": "json", "url": "https://www.youtube.com/watch?v=%s" % ytid}
url = "https://www.youtube.com/oembed"
query_string = urllib.parse.urlencode(params)
url = url + "?" + query_string

response = urllib.request.urlopen(url)
response_text = response.read()
data = json.loads(response_text.decode())
print(f'{data["title"]} [{ytid}]')
