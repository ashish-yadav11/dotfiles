/* compilation:

gcc -o sigdwm -O3 -Wall -Wextra sigdwm.c -lX11

*/
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>

#define ROOTNAMELENGTH                  320
#define FSIGID                          "z:"
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
                        char *stext;

                        for (stext = curname; *stext != '\n' && *stext != '\0'; stext++);
                        if (*stext != '\0' && *(++stext) != '\0')
                                snprintf(newname, sizeof newname, FSIGID "%s\n%s", argv[1], stext);
                        else
                                snprintf(newname, sizeof newname, FSIGID "%s\n", argv[1]);
                } else
                        snprintf(newname, sizeof newname, FSIGID "%s\n%s", argv[1], curname);
        } else
                snprintf(newname, sizeof newname, FSIGID "%s\n", argv[1]);
        XFree(curname);
        XStoreName(dpy, DefaultRootWindow(dpy), newname);
        XCloseDisplay(dpy);
        return 0;
}
