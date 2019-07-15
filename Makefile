#	$OpenBSD$

.if !defined(ATF)

PROGS+=	t_access t_bind t_chroot t_clock_gettime t_dup t_fsync t_getgroups
PROGS+=	t_getitimer t_getlogin t_getpid t_getrusage t_getsid t_getsockname
PROGS+=	t_gettimeofday t_kill t_link t_mkdir t_mkfifo t_mknod t_mmap t_msgctl
PROGS+=	t_msgget t_msync t_pipe t_poll t_revoke t_select t_sendrecv t_setuid
PROGS+=	t_socketpair t_sigaction t_truncate t_umask t_write

# failing tests
PROGS+=	t_listen
PROGS+=	t_mlock
PROGS+=	t_msgrcv
PROGS+=	t_msgsnd
PROGS+=	t_pipe2
PROGS+=	t_ptrace
PROGS+=	t_stat
PROGS+=	t_syscall
PROGS+=	t_unlink

LDADD_t_getpid = 	-lpthread

. for p in ${PROGS}
SRCS_$p = $p.c atf-c.c
. endfor

. for t in ${PROGS}
REGRESS_TARGETS+= run-$t
run-$t: $t
	@echo "\n======== $@ ========"
	@ntests=`./$t -n`; \
	echo "1..$$ntests"; \
	for i in `jot - 1 $$ntests`; do \
	    echo -n "$$i "; \
	    eval `./$t -i $$i`; \
	    ${.MAKE} t=$t ATF=$$i \
		"REQ_USER=$$REQ_USER" "DESCR=\"$$DESCR\""; \
	    unset REQ_USER DESCR; \
	done
. endfor

.else # defined(ATF)

. if ${REQ_USER} == "root"
REGRESS_ROOT_TARGETS+= run-$t-${ATF}
. endif

CUR_USER!=id -g
REGRESS_TARGETS+= run-$t-${ATF}

run-$t-${ATF}:
	@echo ${DESCR}
. if ${REQ_USER} == "root"
	${SUDO} ./$t -r ${ATF}
. elif ${REQ_USER} == "unprivileged" && ${CUR_USER} == 0
	${SUDO} su ${BUILDUSER} -c exec ./$t -r ${ATF}
. else # REQ_USER == ""
	./$t -r ${ATF}
. endif

.endif # defined(ATF)

CLEANFILES+=access dummy mmap

clean: _SUBDIRUSE
	rm -f [Ee]rrs mklog *.core ${PROG} ${PROGS} ${OBJS} ${CLEANFILES}
	${SUDO} rm -rf ./dir

.include <bsd.regress.mk>
