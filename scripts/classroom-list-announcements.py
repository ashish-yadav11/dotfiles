#!/usr/bin/python

import functools
import sys
import dateutil.parser
import dateutil.tz
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google.auth.exceptions import RefreshError


print = functools.partial(print, flush=True)

credsfolder = '/home/ashish/.config/google/classroom'
SCOPES = [
    'https://www.googleapis.com/auth/classroom.announcements.readonly',
    'https://www.googleapis.com/auth/classroom.courses.readonly',
    'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
    'https://www.googleapis.com/auth/classroom.rosters.readonly',
    'https://www.googleapis.com/auth/drive',
]

TZLOCAL = dateutil.tz.tzlocal()


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


def ListAnnouncements(service, courseid, number):
    announcements = []
    page_token = None

    while True:
        response = service.courses().announcements().list(
            courseId=courseid,
            pageToken=page_token,
            pageSize=number
        ).execute()
        announcements.extend(response.get('announcements', []))
        if len(announcements) >= int(number):
            break
        page_token = response.get('nextPageToken', None)
        if not page_token:
            break

    if not announcements:
        print('No announcements found.')
        return

    flag = 0
    for a in announcements:
        if flag:
            print('\n')
        else:
            flag = 1

        try:
            creator = service.userProfiles().get(
                userId=a.get('creatorUserId')).execute()
            print(
                "\033[1;32m"
                f"{creator.get('name').get('fullName')}"
                "\033[0m\n"
            )
        except:
            print(
                "\033[1;32m"
                "Unknown"
                "\033[0m\n"
            )

        updatetime = dateutil.parser.isoparse(
            a.get('updateTime'))
        creationtime = dateutil.parser.isoparse(
                a.get('creationTime'))
        updatetimesec = int(updatetime.strftime('%s'))
        creationtimesec = int(creationtime.strftime('%s'))
        if updatetimesec >= creationtimesec + 60:
            print(
                "\033[31m"
                f"{creationtime.astimezone(TZLOCAL).strftime('%c')}"
                "\033[0m (\033[34m"
                f"{updatetime.astimezone(TZLOCAL).strftime('%c')}"
                "\033[0m)\n"
            )
        else:
            print(
                "\033[34m"
                f"{creationtime.astimezone(TZLOCAL).strftime('%c')}"
                "\033[0m\n"
            )

        print(a.get('text'))

        materials = a.get('materials')
        if not materials:
            continue
        print(
            "\n\033[33m"
            "Attachments:"
            "\033[0m"
        )
        for m in materials:
            link = m.get('link')
            if link:
                print(
                    f"\n\033[35m"
                    f"{link.get('title')}"
                    f"\033[0m\n"
                    f"{link.get('url')}"
                )
                continue

            drivefile = m.get('driveFile')
            if not drivefile:
                continue
            drivefile = drivefile.get('driveFile')
            if not drivefile:
                continue
            print(
                f"\n\033[35m"
                f"{drivefile.get('title')}"
                f"\033[0m\n"
                f"{drivefile.get('id')} "
                f"({drivefile.get('alternateLink')})"
            )


def DieUsage():
    print("Usage: classroom-list-announcements course-id [number]")
    sys.exit(1)


if __name__ == '__main__':
    argc = len(sys.argv)

    if argc < 2 or argc > 3:
        DieUsage()

    courseid = sys.argv[1]
    if not courseid.isdigit():
        DieUsage()

    number = 0
    if argc != 2:
        number = sys.argv[2]
        if not number.isdigit():
            DieUsage()

    service = build('classroom', 'v1', credentials=GetCredentials())
    ListAnnouncements(service, courseid, number)
