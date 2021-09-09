#!/usr/bin/python

import functools
import sys
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google.auth.exceptions import RefreshError


print = functools.partial(print, flush=True)

short = 0

credsfolder = '/home/ashish/.config/google/classroom'
SCOPES = ['https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly']


def GetCredentials():
    creds = None

    if os.path.exists(f"{credsfolder}/clm-token.json"):
        creds = Credentials.from_authorized_user_file(
                f"{credsfolder}/clm-token.json", SCOPES)

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
        with open(f"{credsfolder}/clm-token.json", 'w') as token:
            token.write(creds.to_json())

    return creds


def ListCourseworkMaterials(service, courseid, number):
    materials = []
    page_token = None

    while True:
        response = service.courses().courseWorkMaterials().list(
            courseId=courseid,
            pageToken=page_token,
            pageSize=number
        ).execute()
        materials.extend(response.get('courseWorkMaterial', []))
        if len(materials) >= int(number):
            break
        page_token = response.get('nextPageToken', None)
        if not page_token:
            break

    if not materials:
        print('No coursework materials found.')
        return

    flag = 0
    for mi in materials:
        if not short:
            if flag:
                print()
            else:
                flag = 1
            print(
                "\033[33m"
                f"{mi.get('title')}"
                "\033[0m"
            )
        for mj in mi.get('materials'):
            drivefile = mj.get('driveFile')
            if not drivefile:
                continue
            drivefile = drivefile.get('driveFile')
            if not drivefile:
                continue
            if short:
                print(drivefile.get('id'))
            else:
                print(
                    f"\n\033[35m"
                    f"{drivefile.get('title')}"
                    f"\033[0m\n"
                    f"{drivefile.get('id')} "
                    f"({drivefile.get('alternateLink')})"
                )


def DieUsage():
    print(f"Usage: classroom-list-materials [-s] course-id [number]")
    sys.exit(1)


if __name__ == '__main__':
    argc = len(sys.argv) - 1; argf = 1

    if argc < 1:
        DieUsage()
    
    if sys.argv[argf] == '-s':
        short = 1
        argc -= 1; argf += 1

    if argc < 1 or argc > 2:
        DieUsage()

    courseid = sys.argv[argf]
    argc -= 1; argf += 1
    if not courseid.isdigit():
        DieUsage()

    number = 0
    if argc > 0:
        number = sys.argv[argf]
        if not number.isdigit():
            DieUsage()

    service = build('classroom', 'v1', credentials=GetCredentials())
    ListCourseworkMaterials(service, courseid, number)
