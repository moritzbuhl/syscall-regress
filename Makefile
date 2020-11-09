#	$OpenBSD: Makefile,v 1.6 2020/11/09 23:18:51 bluhm Exp $

# Copyright (c) 2019 Moritz Buhl <openbsd@moritzbuhl.de>
# Copyright (c) 2019 Alexander Bluhm <bluhm@openbsd.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Each test program in PROGS may define several numbered subtests.
# In a first step compile all programs and extract their parameters.
# For each PROG define new regression subtests based on the test number.

.if defined(NUMBERS)
REGRESS_TARGETS =	${NUMBERS:S/^/run-${PROG}-/}
.else
REGRESS_TARGETS =	${PROGS:S/^/run-/}
.endif

PROGS =
PROGS +=	t_access
PROGS +=	t_bind
PROGS +=	t_chroot t_clock_gettime
PROGS +=	t_dup
PROGS +=	t_fsync
PROGS +=	t_getgroups t_getitimer t_getlogin t_getpid t_getrusage
PROGS +=	t_getsid t_getsockname t_gettimeofday
PROGS +=	t_kill
PROGS +=	t_link t_listen
PROGS +=	t_mkdir t_mkfifo t_mknod t_mlock t_mmap 
PROGS +=	t_msgctl t_msgget t_msgrcv t_msgsnd t_msync
PROGS +=	t_pipe t_pipe2 t_poll t_ptrace
PROGS +=	t_revoke
PROGS +=	t_select t_sendrecv t_setuid t_socketpair t_sigaction t_stat
PROGS +=	t_syscall
PROGS +=	t_truncate
PROGS +=	t_umask t_unlink
PROGS +=	t_write

# failing tests
REGRESS_EXPECTED_FAILURES =
REGRESS_EXPECTED_FAILURES +=	run-t_mlock-4
REGRESS_EXPECTED_FAILURES +=	run-t_mmap-1 run-t_mmap-3
REGRESS_EXPECTED_FAILURES +=	run-t_msgrcv-3
REGRESS_EXPECTED_FAILURES +=	run-t_pipe2-2
REGRESS_EXPECTED_FAILURES +=	run-t_stat-1 run-t_stat-4 run-t_stat-5
REGRESS_EXPECTED_FAILURES +=	run-t_stat-6 run-t_stat-8
REGRESS_EXPECTED_FAILURES +=	run-t_syscall-1
REGRESS_EXPECTED_FAILURES +=	run-t_unlink-2

. for p in ${PROGS}
SRCS_$p =		$p.c atf-c.c
. endfor

CFLAGS += -std=gnu99

LDADD_t_getpid =	-lpthread

run-t_truncate: setup-t_truncate
setup-t_truncate:
	${SUDO} touch truncate_test.root_owned
	${SUDO} chown root:wheel truncate_test.root_owned

run-t_chroot: cleanup-dir
run-t_ptrace: cleanup-dir
cleanup-dir:
	${SUDO} rm -rf dir

CLEANFILES =	access dummy mmap truncate_test.root_owned

.for p in ${PROGS}
run-$p: $p
	@echo "\n======== $@ ========"
	ntests="`./$p -n`" && \
	echo "1..$$ntests" && \
	tnumbers="`jot -ns' ' - 1 $$ntests`" && \
	${.MAKE} -C ${.CURDIR} PROG=$p NUMBERS="$$tnumbers" regress
.endfor

.if defined(NUMBERS)
CUR_USER !=		id -g

. for n in ${NUMBERS}
DESCR_$n !=		eval `./${PROG} -i $n` && echo $$DESCR
REQ_USER_$n !=		eval `./${PROG} -i $n` && echo $$REQ_USER

.  if ${REQ_USER_$n} == "root"
REGRESS_ROOT_TARGETS +=	run-${PROG}-$n
.  endif

run-${PROG}-$n:
	@echo "$n ${DESCR_$n}"
.  if ${REQ_USER_$n} == "root"
	${SUDO} ./${PROG} -r $n
.  elif ${REQ_USER_$n} == "unprivileged" && ${CUR_USER} == 0
	${SUDO} su ${BUILDUSER} -c exec ./${PROG} -r $n
.  elif ${REQ_USER_$n} == "unprivileged" || ${REQ_USER_$n} == ""
	./${PROG} -r $n
.  else
	# bad REQ_USER: ${REQ_USER_$n}
	false
.  endif

. endfor
.endif

.include <bsd.regress.mk>
