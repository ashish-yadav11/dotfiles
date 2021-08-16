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


print = functools.partial(print, flush=True)

credsfolder = '/home/ashish/.config/google/classroom'
SCOPES = [
    'https://www.googleapis.com/auth/classroom.announcements.readonly',
    'https://www.googleapis.com/auth/classroom.rosters.readonly'
]

TZLOCAL = dateutil.tz.tzlocal()


def get_creds():
    creds = None

    if os.path.exists(f"{credsfolder}/cla-token.json"):
        creds = Credentials.from_authorized_user_file(
                f"{credsfolder}/cla-token.json", SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                f"{credsfolder}/credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)
        with open(f"{credsfolder}/cla-token.json", 'w') as token:
            token.write(creds.to_json())

    return creds


def list_announcements(service, courseid, number):
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
            "\033[33m"
            "Attachments:"
            "\033[0m"
        )
        for m in materials:
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


def die_usage():
    print(f"Usage: classroom-list-announcements course-id [number]")
    sys.exit(1)


if __name__ == '__main__':
    argc = len(sys.argv)

    if argc < 2 or argc > 3:
        die_usage()

    courseid = sys.argv[1]
    if not courseid.isdigit():
        die_usage()

    number = 0
    if argc != 2:
        number = sys.argv[2]
        if not number.isdigit():
            die_usage()

    service = build('classroom', 'v1', credentials=get_creds())
    list_announcements(service, courseid, number)
