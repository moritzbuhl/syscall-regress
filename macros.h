/*	$OpenBSD$	*/
/* Public domain - Moritz Buhl */

#include <sys/param.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/types.h>

#include <stdbool.h>
#include <string.h>

#define __RCSID(str)
#define __COPYRIGHT(str)

#define __arraycount(_a)	nitems(_a)

/* t_chroot.c */
#define fchroot(fd) 0

/* t_clock_gettime.c */
int sysctlbyname(char *, void *, size_t *, void *, size_t);

int
sysctlbyname(char* s, void *oldp, size_t *oldlenp, void *newp, size_t newlen)
{
	int ktc;
	if (strcmp(s, "kern.timecounter.hardware") == 0)
		ktc = KERN_TIMECOUNTER_HARDWARE;
	else if (strcmp(s, "kern.timecounter.choice") == 0)
		ktc = KERN_TIMECOUNTER_CHOICE;

        int mib[3];
	mib[0] = CTL_KERN;
	mib[1] = KERN_TIMECOUNTER;
	mib[2] = ktc;
        return sysctl(mib, 3, oldp, oldlenp, newp, newlen);
}

/* t_mlock.c */
#define MAP_WIRED	__MAP_NOREPLACE
