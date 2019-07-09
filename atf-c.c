/*	$OpenBSD$	*/

#include <sys/wait.h>

#include <err.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <pwd.h>
#include <unistd.h>

#include "atf-c.h"

void usage(void);

int cleanup;
int count;
int inspect;
int run;
int test;

int
main(int argc, char *argv[])
{
	int ch, test;
	const char *errstr, *num;

	while ((ch = getopt(argc, argv, "c:i:nr:")) != -1) {
		switch(ch) {
		case 'c':
			cleanup = 1;
			num = optarg;
			break;
		case 'i':
			inspect = 1;
			num = optarg;
			break;
		case 'n':
			count = 1;
			break;
		case 'r':
			run = 1;
			num = optarg;
			break;
		default:
			usage();
		}
	}
	argc -= optind;
	argv += optind;

	if (cleanup + count + inspect + run > 1)
		usage();

	if (cleanup || inspect || run) {
		test = strtonum(num, 1, INT_MAX, &errstr);
		if (errstr != NULL)
			errx(1, "test # is %s: %s", errstr, argv[1]);
	}
	if (count)
		printf("%d\n", atf_test(0, 0));
	else if (cleanup)
		ATF_CLEANUP(test);
	else if (run)
		ATF_RUN(test);
	else if (inspect)
		ATF_INSPECT(test);
	else
		usage();

	return 0;
}

void
usage(void)
{
	fprintf(stderr, "usage: %s [-n] [-c|i|r test#]\n", getprogname());
	exit(1);
}
