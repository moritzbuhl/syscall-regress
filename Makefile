#	$OpenBSD$

.if !defined(ATF)

PROGS=
PROGS+=	t_access t_bind t_chroot t_clock_gettime t_dup t_fsync t_getgroups
PROGS+=	t_getitimer t_getlogin t_getpid t_getrusage t_getsid t_getsockname
PROGS+=	t_gettimeofday t_kill t_link t_listen t_mkdir t_mknod t_msgctl
PROGS+=	t_msgget t_msgsnd t_msync t_pipe t_poll t_revoke t_select t_sendrecv
PROGS+= t_setuid t_socketpair t_sigaction t_truncate t_umask t_write

. if 0
# failing tests
PROGS+=	t_mkfifo
PROGS+=	t_mlock
PROGS+=	t_mmap
PROGS+=	t_msgrcv
PROGS+=	t_pipe2
PROGS+=	t_ptrace
PROGS+=	t_stat
PROGS+=	t_syscall
PROGS+=	t_unlink
. endif

. for p in ${PROGS}
SRCS_$p =		$p.c atf-c.c
. endfor

LDADD_t_getpid =	-lpthread

REGRESS_TARGETS =
REGRESS_ROOT_TARGETS =

. for t in ${PROGS}
REGRESS_TARGETS +=	run-$t
run-$t: $t
	@echo "\n======== $@ ========"
	ntests=`./$t -n`; \
	echo "1..$$ntests"; \
	for i in `jot - 1 $$ntests`; do \
	    echo -n "$$i "; \
	    eval `./$t -i $$i`; \
	    ${MAKE} -C ${.CURDIR} TEST=$t ATF=$$i \
		"REQ_USER=$$REQ_USER" "DESCR=\"$$DESCR\"" \
		$@-$$i; \
	done
. endfor

.else # defined(ATF)

. if ${REQ_USER} == "root"
REGRESS_ROOT_TARGETS +=	run-${TEST}-${ATF}
. endif

CUR_USER !=		id -g
REGRESS_TARGETS +=	run-${TEST}-${ATF}

run-${TEST}-${ATF}:
	@echo ${DESCR}
. if ${REQ_USER} == "root"
	${SUDO} ./${TEST} -r ${ATF}
. elif ${REQ_USER} == "unprivileged" && ${CUR_USER} == 0
	${SUDO} su ${BUILDUSER} -c exec ./${TEST} -r ${ATF}
. elif ${REQ_USER} == "unprivileged" || ${REQ_USER} == ""
	./${TEST} -r ${ATF}
. else
	# bad REQ_USER: ${REQ_USER}
	false
. endif

.endif # defined(ATF)

run-t_truncate: setup-t_truncate
setup-t_truncate:
	${SUDO} touch truncate_test.root_owned
	${SUDO} chown root:wheel truncate_test.root_owned

run-t_chroot: cleanup-t_chroot
cleanup-t_chroot:
	${SUDO} rm -rf ./dir

CLEANFILES +=	access dummy mmap truncate_test.root_owned

.include <bsd.regress.mk>

clean: cleanup-t_chroot
