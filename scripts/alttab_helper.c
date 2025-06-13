/* compilation:

gcc -o alttab_helper -O3 -Wall -Wextra alttab_helper.c -lX11

*/
#include <X11/Xlib.h>
#include <X11/XKBlib.h>
#include <stdio.h>

int
main(void)
{
        Display *dpy;
        XkbStateRec state;

        if (!(dpy = XOpenDisplay(NULL))) {
                fputs("Error: could not open display.\n", stderr);
                return 2;
        }
        if (XkbGetState(dpy, XkbUseCoreKbd, &state) != Success) {
                fputs("Error: XkbGetState failed.\n", stderr);
                XCloseDisplay(dpy);
                return 2;
        }
        XCloseDisplay(dpy);
        return state.mods & Mod4Mask ? 0 : 1;
}
