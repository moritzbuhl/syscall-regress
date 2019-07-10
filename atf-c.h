/*	$OpenBSD$	*/
/*
 * Copyright (c) 2019 Moritz Buhl <openbsd@moritzbuhl.de>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#if !defined(ATF_C_H)
#define ATF_C_H

#include <err.h>
#include <pwd.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>


int atf_test(int, int);

#define ATF_INSPECT_TEST	1
#define ATF_RUN_TEST		2
#define ATF_CLEANUP_TEST	3

#define ATF_TC_FUNCTIONS(fn)						\
void atf_head_##fn(void);						\
void atf_body_##fn(void);						\
void atf_cleanup_##fn(void);						\

#define ATF_TC(fn)							\
ATF_TC_FUNCTIONS(fn)							\
void atf_cleanup_##fn(void) { return; }	

#define ATF_TC_WITH_CLEANUP(fn)						\
ATF_TC_FUNCTIONS(fn)

#define ATF_TC_HEAD(fn, tc)	void atf_head_##fn(void)
#define ATF_TC_BODY(fn, tc) 	void atf_body_##fn(void)
#define ATF_TC_CLEANUP(fn, tc)	void atf_cleanup_##fn(void)

#define ATF_TP_ADD_TCS(tp)	int atf_test(int tst, int what)
#define ATF_TP_ADD_TC(tp, fn)	tst--;					\
	if (tst == 0) {							\
		if (what == ATF_INSPECT_TEST)				\
			atf_head_##fn();				\
		else if (what == ATF_RUN_TEST)				\
			atf_body_##fn();				\
		else if (what == ATF_CLEANUP_TEST)			\
			atf_cleanup_##fn();				\
		return 0;						\
	}

#define atf_no_error()	(-tst)

#define ATF_INSPECT(i)		atf_test(i, ATF_INSPECT_TEST)
#define ATF_RUN(i)		atf_test(i, ATF_RUN_TEST)
#define ATF_CLEANUP(i)		atf_test(i, ATF_CLEANUP_TEST)

#define atf_tc_set_md_var(tc, attr, fmt, ...)				\
	if (strcmp(attr, "descr") == 0) {				\
		printf("DESCR='" fmt "'\n", ##__VA_ARGS__);		\
	} else if (strcmp(attr, "require.user") == 0) {			\
		if (strcmp(fmt, "unprivileged") == 0)			\
			printf("REQ_USER=nobody\n");			\
		else if (strcmp(fmt, "root") == 0)			\
			printf("REQ_USER=root\n");			\
	}

#define ATF_CHECK		ATF_REQUIRE
#define ATF_CHECK_MSG		ATF_REQUIRE_MSG

#define ATF_REQUIRE(exp)		if (!(exp)) err(1, __func__)
#define ATF_REQUIRE_ERRNO(no, exp)	if (!(exp)) err(1, "!("#exp")");\
	else if (errno != no) err(1, "(errno != " #no)
#define ATF_REQUIRE_MSG(exp, fmt, ...)	if (!(exp))			\
	err(1, fmt, ##__VA_ARGS__)
#define ATF_REQUIRE_EQ(a, b)		if ((a) != (b)) err(1, __func__)

#define atf_tc_fail(fmt, ...)		err(1, fmt, ##__VA_ARGS__)
#define atf_tc_fail_nonfatal(fmt, ...)	atf_tc_fail(fmt, ##__VA_ARGS__)
#define atf_tc_expect_fail(fmt, ...)	atf_tc_fail(fmt, ##__VA_ARGS__)
#define atf_tc_skip(fmt, ...)		atf_tc_fail(fmt, ##__VA_ARGS__)

#endif /* !defined(ATF_C_H) */
