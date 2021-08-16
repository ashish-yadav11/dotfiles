#!/usr/bin/python

import re
import sys
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials


credsfolder = '/home/ashish/.config/google/drive'
SCOPES = ['https://www.googleapis.com/auth/drive']


def get_creds():
    creds = None

    if os.path.exists(f"{credsfolder}/ads-token.json"):
        creds = Credentials.from_authorized_user_file(
            f"{credsfolder}/ads-token.json", SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                f"{credsfolder}/credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)
        with open(f"{credsfolder}/ads-token.json", 'w') as token:
            token.write(creds.to_json())

    return creds


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


def get_shortcuts_in_folder(service, folderid):
    shortcuts = []
    page_token = None
    while True:
        response = service.files().list(
            q=f"trashed = false and '{folderid}' in parents and " \
               "mimeType = 'application/vnd.google-apps.shortcut'",
            fields='nextPageToken, files(shortcutDetails)',
            pageToken=page_token,
        ).execute()
        for shortcut in response.get('files', []):
            targetid = shortcut.get('shortcutDetails').get('targetId')
            shortcuts.append(targetid)
        page_token = response.get('nextPageToken', None)
        if not page_token:
            break

    return shortcuts


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
        fileId=shortcut.get('shortcutDetails').get('targetId')
    ).execute()

    print(
        "\033[1;32m"
        "Shortcut file"
        "\033[0m\n"
        f"name: {shortcut.get('name')}, id: {shortcut.get('id')}\n"
        "\033[1;32m"
        "Target file"
        "\033[0m\n"
        f"name: {target.get('name')}, id: {target.get('id')}, "
        f"mimetype: {target.get('mimeType')}"
    )


def die_usage():
    print(
        "Usage: add-drive-shortcut"
        f" [-c] ([-f folder-id] target-url|target-id [-n name])..."
    )
    sys.exit(1)


if __name__ == '__main__':
    argc = len(sys.argv) - 1; argf = 1

    clobber = 0
    if argc > 0 and sys.argv[1] == '-c':
        clobber = 1
        argc -= 1; argf += 1

    service = None
    foldershortcuts = []
    oldfolderid = ''
    folderid = 'root'
    flag = 0
    while argc > 0:
        if flag:
            print()
        else:
            flag = 1

        if argc > 0 and sys.argv[argf] == '-f':
            argc -= 1; argf += 1
            if argc > 0:
                folderid = sys.argv[argf]
                argc -= 1; argf += 1

        if not argc > 0:
            break
        target = sys.argv[argf]
        argc -= 1; argf += 1

        filename = None
        if argc > 0 and sys.argv[argf] == '-n':
            argc -= 1; argf += 1
            if argc > 0:
                filename = sys.argv[argf]
                argc -= 1; argf += 1

        targetid = get_target_id(target)

        if not service:
            service = build('drive', 'v3', credentials=get_creds())

        if folderid != oldfolderid:
            oldfolderid = folderid
            foldershortcuts = get_shortcuts_in_folder(service, folderid)

        if clobber or targetid not in foldershortcuts:
            add_shortcut_to_drive(service, folderid, filename, targetid)
        else:
            flag = 0

    if not service:
        die_usage()
