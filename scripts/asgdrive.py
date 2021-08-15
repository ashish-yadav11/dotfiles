#!/usr/bin/python
# Add shortcut to google drive

import re
import sys
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials


credfolder = '/home/ashish/.config/gdrive-cli'
SCOPES = ['https://www.googleapis.com/auth/drive']


def init_service():
    creds = None

    if os.path.exists(f"{credfolder}/token.json"):
        creds = Credentials.from_authorized_user_file(
                f"{credfolder}/token.json", SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                f"{credfolder}/credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)
        with open(f"{credfolder}/token.json", 'w') as token:
            token.write(creds.to_json())

    return build('drive', 'v3', credentials=creds)


def get_target_id(target):
    idpatterns = [
        re.compile('/file/d/([0-9A-Za-z_-]{10,})(?:/|$)', re.IGNORECASE),
        re.compile('/folders/([0-9A-Za-z_-]{10,})(?:/|$)', re.IGNORECASE),
        re.compile('id=([0-9A-Za-z_-]{10,})(?:&|$)', re.IGNORECASE),
        re.compile('([0-9A-Za-z_-]{10,})', re.IGNORECASE)
    ]

    for pattern in idpatterns:
        match = pattern.search(target)
        if match:
            return match.group(1)

    print(f"Error: unable to get ID from {target}")
    sys.exit(1)


def add_shortcut_to_drive(service, folderid, filename, targetid):
    metadata = {
        'mimeType': 'application/vnd.google-apps.shortcut',
        'parents': [folderid],
        'shortcutDetails': {
            'targetId': targetid
        }
    }
    if filename:
        metadata['name'] = filename

    shortcut = service.files().create(
        body=metadata, fields='name,id,shortcutDetails'
    ).execute()

    target = service.files().get(
        fileId=shortcut['shortcutDetails']['targetId']
    ).execute()

    print(
        '\033[1;32mShortcut file\033[0m\n'
            f"name: {shortcut['name']}, id: {shortcut['id']}\n"
        '\033[1;32mTarget file\033[0m\n'
            f"name: {target['name']}, id: {target['id']}, "
            f"mimetype: {target['mimeType']}"
    )


def die_usage(progname):
    print(f"Usage: {sys.argv[0]} [-f folder-id] target-url|id [-n name]...")
    sys.exit(1)


if __name__ == '__main__':
    progname = sys.argv[0]
    argc = len(sys.argv) - 1; argf = 1
    if argc < 1:
        die_usage(progname)

    service = None
    folderid = 'root'
    while argc > 0:
        if argf != 1:
            print()

        if argc > 0 and sys.argv[argf] == '-f':
            argf += 1; argc -= 1
            if argc > 0:
                folderid = sys.argv[argf]
                argf += 1; argc -= 1
            elif argf == 2:
                die_usage(progname)

        target = sys.argv[argf]
        argf += 1; argc -= 1

        filename = None
        if argc > 0 and sys.argv[argf] == '-n':
            argf += 1; argc -= 1
            if argc > 0:
                filename = sys.argv[argf]
                argf += 1; argc -= 1

        targetid = get_target_id(target)
        if not service:
            service = init_service()
        add_shortcut_to_drive(service, folderid, filename, targetid)
