/*	$OpenBSD$	*/

#include <sys/wait.h>

#include <err.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <pwd.h>
#include <unistd.h>

#include "atf-c.h"

int atf_skip = 0;
char atf_descr[2048];
char atf_user[_PW_NAME_LEN + 5];

void tests_run(int);
void test_exec(int);

int
main(int argc, char *argv[])
{
	int test;
	const char *errstr;

	if (argc == 2) {
		test = strtonum(argv[1], 1, INT_MAX, &errstr);
		if (errstr != NULL)
			errx(1, "test # is %s: %s", errstr, argv[1]);
		ATF_RUN(test);
		return 0;
	} else if (argc != 1) {
		fprintf(stderr, "usage: %s [test#]\n", getprogname());
		exit(2);
	}

	tests_run(atf_test(0, 0));
	return 0;
}

void
tests_run(int tests)
{
	int i, sta;
	for (i = 1; i <= tests; i++) {
		ATF_INIT(i);
		printf("%s %s\n", atf_descr, atf_user);
		atf_user[0] = '\0';
		if (atf_skip) {
			atf_skip = 0;
			printf("SKIPPED\n");
			continue;
		}

		test_exec(i);
		wait(&sta);
		if (WIFEXITED(sta) == 0 || WEXITSTATUS(sta) != EXIT_SUCCESS)
			printf("FAILED\n");
		else
			printf("SUCCESS\n");
		ATF_CLEANUP(i);
	}
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
