/*	$OpenBSD$	*/

#include <sys/wait.h>

#include <err.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "atf-c.h"

int atf_skip = 0;

void test_exec(int);

int
main(int argc, char *argv[])
{
	int test, i, sta;
	const char *errstr;

	if (argc == 1) {
		test = 0;
	} else if (argc == 2) {
		test = strtonum(argv[1], 1, INT_MAX, &errstr);
		if (errstr != NULL)
			errx(1, "test # is %s: %s", errstr, argv[1]);
		ATF_RUN(test);
		return 0;
	}

	test = atf_test(0, 0);
	for (i = 1; i <= test; i++) {
		ATF_INIT(i);
		if (atf_skip) {
			atf_skip = 0;
			printf("SKIPPED\n");
			continue;
		}

		test_exec(i);
		wait(&sta);
		if (WIFEXITED(sta) == 0 || WEXITSTATUS(sta) != EXIT_SUCCESS)
			printf("FAILED\n");
		ATF_CLEANUP(i);
	}
	return 0;
}

void
test_exec(int test)
{
	pid_t test_pid;
	char *prog;
	char *argv[3];

	if (asprintf(&prog, "./%s", getprogname()) == -1)
		err(1, "asprintf prog");
	if (asprintf(&argv[0], "%s", getprogname()) == -1)
		err(1, "asprintf progname");
	if (asprintf(&argv[1], "%d", test) == -1)
		err(1, "asprintf test #");
	argv[2] = NULL;

	test_pid = fork();
	if (test_pid == - 1)
		err(1, "fork");
	if (test_pid == 0) {
		execvp(prog, argv);
		err(255, "test exec");
	}

	free(prog);
	free(argv[0]);
	free(argv[1]);
}
