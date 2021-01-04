/* compilation:

gcc -o pixelcolor -O3 -Wall -Wextra pixelcolor.c -lX11

*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#define USAGE                           "Usage: pixelcolor [x] [y] [w] [h]\n"

int quiet = 0;
Display *dpy;

void
getmouselocation(int *x, int *y)
{
        int di;
        unsigned int dui;
        Window dummy;

        XQueryPointer(dpy, DefaultRootWindow(dpy), &dummy, &dummy, &di, &di, x, y, &dui);
}

int
parseint(char *arg, int *i)
{
        int j = 0;

        for (; *arg != '\0'; arg++)
                if (*arg >= '0' && *arg <= '9')
                        j = 10 * j + *arg - '0';
                else
                        return 0;
        *i = j;
        return 1;
}

void
printcolors(int x, int y, int w, int h)
{
        XImage *image;

        if (!(image = XGetImage(dpy, DefaultRootWindow(dpy), x, y, w, h, AllPlanes, XYPixmap))) {
                fputs("Error: XGetImage failed.\n", stderr);
                XCloseDisplay(dpy);
                exit(1);
        }
        for (int i = 0; i < h; i++)
                for (int j = 0; j < w; j++)
                        if (quiet)
                                printf("#%06x\n", (int)(XGetPixel(image, j, i) & 0xffffff));
                        else
                                printf("%d,%d:#%06x\n", x + j, y + i, (int)(XGetPixel(image, j, i) & 0xffffff));

        XDestroyImage(image);
}
 
int
main(int argc, char *argv[])
{
        int pargc = argc - 1;
        char **pargv = argv + 1;
        int v[4] = { 0, 0, 1, 1 };

        if (!(dpy = XOpenDisplay(NULL))) {
                fputs("Error: could not open display.\n", stderr);
                return 1;
        }
        if (argc > 1 && strcmp(argv[1], "-q") == 0) {
                quiet = 1;
                pargc--, pargv++;
        }
        if (!pargc)
                getmouselocation(&v[0], &v[1]);
        else
                for (int i = 0; i < pargc; i++)
                        if (!parseint(pargv[i], &v[i])) {
                                fprintf(stderr, "Usage: %s [x] [y] [w] [h]\n", argv[0]);
                                XCloseDisplay(dpy);
                                return 1;
                        }
        printcolors(v[0], v[1], v[2], v[3]);
        XCloseDisplay(dpy);
        return 0;
}
