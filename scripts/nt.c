/* compilation:

gcc -o nt -O3 -Wall -Wextra nt.c

*/

#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define USAGE \
        "Usage:\n" \
        "	nt <time-interval> <notification>\n" \
        "Examples:\n" \
        "	nt 1h10m30s go to sleep\n" \
        "	nt \"1H 10M 30S\" go to sleep\n" \
        "	nt 1,10,30 go to sleep\n" \
        "	nt 1:10:30 go to sleep\n" \
        "	nt 1.10.30 go to sleep"

unsigned int
parsetime(char *c)
{
        unsigned int i = 0, t = 0;

        for (; *c != '\0'; c++) {
                if (*c >= '0' && *c <= '9') {
                        i *= 10;
                        i += *c - '0';
                } else if (*c == 's' || *c == 'S') {
                        t += i;
                        i = 0;
                } else if (*c == 'm' || *c == 'M') {
                        t += 60 * i;
                        i = 0;
                } else if (*c == 'h' || *c == 'H') {
                        t += 60 * 60 * i;
                        i = 0;
                } else if (*c == ',' || *c == ':' || *c == '.')
                        i *= 60;
                else if (isspace((unsigned int) *c))
                        continue;
                else {
                        fputs("nt: garbled time", stderr);
                        exit(2);
                }
        }
        return t + i;
}

/* the following function assumes n >= 1 */
char *
catarray(int n, char *array[])
{
        char *c;
        char *buf;
        int t = 0;
        int l[n];

        for (int i = 0; i < n; i++)
                t += l[i] = strlen(array[i]);
        c = buf = malloc((t + n) * sizeof(char));
        memcpy(c, array[0], l[0]);
        c += l[0];
        for (int i = 1; i < n; c += l[i], i++) {
                *(c++) = ' ';
                memcpy(c, array[i], l[i]);
        }
        *c = '\0';
        return buf;
}

int
main(int argc, char *argv[])
{
        char *nbuf;
        unsigned int s;
        time_t t;
        int fd[2];

        if (argc == 2 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)) {
                puts(USAGE);
                return 0;
        }
        if (argc < 3) {
                fputs("nt: incorrect invocation\n", stderr);
                puts(USAGE);
                return 2;
        }
        t = time(NULL);
        /* parse time */
        if (!(s = parsetime(argv[1]))) {
                fputs("nt: incorrect invocation\n", stderr);
                puts(USAGE);
                return 2;
        }
        /* fill notification buffer */
        nbuf = catarray(argc - 2, argv + 2);
        if (nbuf[0] == '\0') {
                fputs("nt: incorrect invocation\n", stderr);
                puts(USAGE);
                free(nbuf);
                return 2;
        }
        /* call at */
        if (pipe(fd) == -1) {
                perror("main - pipe");
                free(nbuf);
                return 1;
        }
        switch (fork()) {
                case -1:
                        perror("main - fork");
                        free(nbuf);
                        return 1;
                case 0:
                {
                        char tbuf[25];
                        char *arg[] = { "/usr/bin/at", tbuf, NULL };

                        close(fd[1]);
                        if (fd[0] != STDIN_FILENO) {
                                if (dup2(fd[0], STDIN_FILENO) != STDIN_FILENO) {
                                        perror("main - child - dup2");
                                        free(nbuf);
                                        return 1;
                                }
                                close(fd[0]);
                        }
                        snprintf(tbuf, sizeof tbuf, "now + %u minutes", s / 60);
                        execv(arg[0], arg);
                        perror("main - child - execv");
                        _exit(127);
                }
                default:
                        close(fd[0]);
                        dprintf(fd[1], "sleep \"$(( %ld - $(date +%%s) ))\"\n"
                                       "notify-send -t 0 '%s'", t + s, nbuf);
                        close(fd[1]);
                        free(nbuf);
                        if (wait(NULL) == -1) {
                                perror("main - wait");
                                return 1;
                        }
        }
        return 0;
}
