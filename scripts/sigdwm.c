/*
        gcc -o sigdwm -O3 -Wall -Wextra sigdwm.c -lX11
*/

#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>

#define FSIGID                          "z:"
#define ROOTNAMELENGTH                  320
#define FSIGIDLEN                       (sizeof FSIGID - 1)

int
main(int argc, char *argv[])
{
        char *curname;
        char newname[ROOTNAMELENGTH];
        Display *dpy;

        if (argc != 2)
                return 2;
        if (!(dpy = XOpenDisplay(NULL))) {
                fputs("Error: could not open display.\n", stderr);
                return 1;
        }
        if (XFetchName(dpy, DefaultRootWindow(dpy), &curname) && curname[0]) {
                if (strncmp(curname, FSIGID, FSIGIDLEN) == 0) {
                        char *curstext;

                        for (curstext = curname; *curstext != '\n' && *curstext != '\0'; curstext++);
                        if (*curstext != '\0' && *(++curstext) != '\0')
                                snprintf(newname, sizeof newname, "%s%s\n%s", FSIGID, argv[1], curstext);
                        else
                                snprintf(newname, sizeof newname, "%s%s\n", FSIGID, argv[1]);
                } else
                        snprintf(newname, sizeof newname, "%s%s\n%s", FSIGID, argv[1], curname);
        } else
                snprintf(newname, sizeof newname, "%s%s\n", FSIGID, argv[1]);
        XFree(curname);
        XStoreName(dpy, DefaultRootWindow(dpy), newname);
        XCloseDisplay(dpy);
        return 0;
}
