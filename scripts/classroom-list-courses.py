#!/usr/bin/python
# Add shortcut to google drive

import functools
import sys
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google.auth.exceptions import RefreshError


print = functools.partial(print, flush=True)

credsfolder = '/home/ashish/.config/google/classroom'
SCOPES = ['https://www.googleapis.com/auth/classroom.courses.readonly']


def GetCredentials():
    creds = None

    if os.path.exists(f"{credsfolder}/clc-token.json"):
        creds = Credentials.from_authorized_user_file(
                f"{credsfolder}/clc-token.json", SCOPES)

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
        with open(f"{credsfolder}/clc-token.json", 'w') as token:
            token.write(creds.to_json())

    return creds


def ListCourse(service, number):
    courses = []
    page_token = None

    while True:
        response = service.courses().list(
            pageToken=page_token,
            pageSize=number
        ).execute()
        courses.extend(response.get('courses', []))
        page_token = response.get('nextPageToken', None)
        if not page_token:
            break

    if not courses:
        print('No courses found.')
        return

    for c in courses:
        print(
            "\033[33m"
            f"{c.get('name')} "
            "\033[0m"
            f"{c.get('id')}"
        )


def DieUsage():
    print(f"Usage: classroom-list-courses [number]")
    sys.exit(1)


if __name__ == '__main__':
    argc = len(sys.argv)

    if argc > 2:
        DieUsage()

    number = 0
    if argc == 2:
        number = sys.argv[1]
        if not number.isdigit():
            DieUsage()

    service = build('classroom', 'v1', credentials=GetCredentials())
    ListCourse(service, number)
