/* compilation:

gcc -o focusedwinclass -O3 -Wall -Wextra focusedwinclass.c -lX11

*/

#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#define DELIMITER                       " : "

enum { Both, Class, Instance };

int
main(int argc, char *argv[])
{
        int print = Both;
        int rtr; /* unused */
        unsigned int nc; /* unused */
        Display *dpy;
        Window win, winr, winp;
        Window *winc; /* unused */
        XClassHint ch = { NULL, NULL };

        if (argc == 2 && strcmp(argv[1], "-c") == 0)
                print = Class;
        else if (argc == 2 && strcmp(argv[1], "-i") == 0)
                print = Instance;
        else if (argc != 1) {
                fprintf(stderr, "Usage: %s [-c|-i]\n", argv[0]);
                return 2;
        }
        if (!(dpy = XOpenDisplay(NULL))) {
                fputs("Error: could not open display.\n", stderr);
                return 1;
        }
        XGetInputFocus(dpy, &win, &rtr);
        while (XQueryTree(dpy, win, &winr, &winp, &winc, &nc) && winp != winr)
                win = winp;
        XGetClassHint(dpy, win, &ch);
        switch (print) {
                case Class:
                        puts(ch.res_class ? ch.res_class : "");
                        break;
                case Instance:
                        puts(ch.res_name ? ch.res_name : "");
                        break;
                case Both:
                        printf("%s" DELIMITER "%s\n",
                               ch.res_class ? ch.res_class : "",
                               ch.res_name ? ch.res_name : "");
                        break;
        }
        if (winc)
                XFree(winc);
        if (ch.res_class)
                XFree(ch.res_class);
        if (ch.res_name)
                XFree(ch.res_name);
        XCloseDisplay(dpy);
        return 0;
}
