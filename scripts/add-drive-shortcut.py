#!/usr/bin/python

import re
import sys
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google.auth.exceptions import RefreshError


credsfolder = '/home/ashish/.config/google/classroom'
SCOPES = [
    'https://www.googleapis.com/auth/classroom.announcements.readonly',
    'https://www.googleapis.com/auth/classroom.courses.readonly',
    'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
    'https://www.googleapis.com/auth/classroom.rosters.readonly',
    'https://www.googleapis.com/auth/drive',
]

foldershortcuts = []


def GetCredentials():
    creds = None

    if os.path.exists(f"{credsfolder}/token.json"):
        creds = Credentials.from_authorized_user_file(
                f"{credsfolder}/token.json", SCOPES)

    if not creds or not creds.valid:
        flag = creds and creds.expired and creds.refresh_token
        if flag:
            try:
                creds.refresh(Request())
            except RefreshError:
                flag = 0
        if not flag:
            stdout_fileno = sys.stdout.fileno()
            stderr_fileno = sys.stderr.fileno()
            orig_stdout_fileno = os.dup(stdout_fileno)
            os.dup2(stderr_fileno, stdout_fileno)

            flow = InstalledAppFlow.from_client_secrets_file(
                f"{credsfolder}/credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)

            os.dup2(orig_stdout_fileno, stdout_fileno)
        with open(f"{credsfolder}/token.json", 'w') as token:
            token.write(creds.to_json())

    return creds


def GetTargetId(target):
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


def FillFolderShortcuts(service, folderid):
    foldershortcuts.clear()
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
            foldershortcuts.append(targetid)
        page_token = response.get('nextPageToken', None)
        if not page_token:
            break


def AddShortcutToDrive(service, folderid, filename, targetid):
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
    foldershortcuts.append(target.get('id'))


def DieUsage():
    print(
        "Usage: add-drive-shortcut"
        " [-c] ([-f folder-id] target-url|target-id [-n name])..."
    )
    sys.exit(1)


if __name__ == '__main__':
    argc = len(sys.argv) - 1; argf = 1

    clobber = 0
    if argc > 0 and sys.argv[1] == '-c':
        clobber = 1
        argc -= 1; argf += 1

    service = None
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

        targetid = GetTargetId(target)

        if not service:
            service = build('drive', 'v3', credentials=GetCredentials())

        if folderid != oldfolderid:
            oldfolderid = folderid
            FillFolderShortcuts(service, folderid)

        if clobber or targetid not in foldershortcuts:
            AddShortcutToDrive(service, folderid, filename, targetid)
        else:
            flag = 0

    if not service:
        DieUsage()
