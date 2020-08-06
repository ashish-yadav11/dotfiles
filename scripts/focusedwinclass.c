#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

int
main(int argc, char *argv[])
{
        int rtr; /* unused */
        unsigned int nc; /* unused */
        const char *class, *instance;
        Display *dpy;
        Window win, winr, winp;
        Window *winc; /* unused */
	XClassHint ch = { NULL, NULL };

        if (!(dpy = XOpenDisplay(NULL))) {
                fputs("Error: could not open display.\n", stderr);
                return 1;
        }
	XGetInputFocus(dpy, &win, &rtr);
	while (XQueryTree(dpy, win, &winr, &winp, &winc, &nc) && winp != winr)
                win = winp;
	XGetClassHint(dpy, win, &ch);
        class = ch.res_class ? ch.res_class : "";
        instance = ch.res_name ? ch.res_name : "";

        if (argc > 1) {
                if (strcmp(argv[1], "-c") == 0)
                        puts(class);
                else if (strcmp(argv[1], "-i") == 0)
                        puts(instance);
                else
                        fprintf(stderr, "Usage: %s [-c] [-i]\n", argv[0]);
        } else
                printf("%s : %s\n", class, instance);

        if (winc)
                XFree(winc);
	if (ch.res_class)
		XFree(ch.res_class);
	if (ch.res_name)
		XFree(ch.res_name);
        return 0;
}
