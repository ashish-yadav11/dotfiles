#!/usr/bin/python

import functools
import sys
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials


print = functools.partial(print, flush=True)

short = 0

credsfolder = '/home/ashish/.config/google/classroom'
SCOPES = ['https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly']


def get_creds():
    creds = None

    if os.path.exists(f"{credsfolder}/clm-token.json"):
        creds = Credentials.from_authorized_user_file(
                f"{credsfolder}/clm-token.json", SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                f"{credsfolder}/credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)
        with open(f"{credsfolder}/clm-token.json", 'w') as token:
            token.write(creds.to_json())

    return creds


def list_coursework_materials(service, courseid, number):
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


def die_usage():
    print(f"Usage: classroom-list-materials [-s] course-id [number]")
    sys.exit(1)


if __name__ == '__main__':
    argc = len(sys.argv) - 1; argf = 1

    if argc < 1:
        die_usage()
    
    if sys.argv[argf] == '-s':
        short = 1
        argc -= 1; argf += 1

    if argc < 1 or argc > 2:
        die_usage()

    courseid = sys.argv[argf]
    argc -= 1; argf += 1
    if not courseid.isdigit():
        die_usage()

    number = 0
    if argc > 0:
        number = sys.argv[argf]
        if not number.isdigit():
            die_usage()

    service = build('classroom', 'v1', credentials=get_creds())
    list_coursework_materials(service, courseid, number)