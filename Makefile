#	$OpenBSD$

.if !defined(ATF)

PROGS +=		t_access
PROGS +=		t_bind
PROGS +=		t_chroot
PROGS +=		t_clock_gettime
PROGS +=		t_dup
PROGS +=		t_fsync
PROGS +=		t_getgroups
PROGS +=		t_getitimer
PROGS +=		t_getlogin
PROGS +=		t_getpid
PROGS +=		t_getrusage
PROGS +=		t_getsid
PROGS +=		t_getsockname
PROGS +=		t_gettimeofday
PROGS +=		t_kill
PROGS +=		t_link
PROGS +=		t_listen
PROGS +=		t_mkdir
PROGS +=		t_mkfifo
PROGS +=		t_mknod
PROGS +=		t_mlock
PROGS +=		t_mmap
PROGS +=		t_msgctl
PROGS +=		t_msgget
PROGS +=		t_msgrcv
PROGS +=		t_msgsnd
PROGS +=		t_msync
PROGS +=		t_pipe
PROGS +=		t_pipe2
PROGS +=		t_poll
PROGS +=		t_ptrace
PROGS +=		t_revoke
PROGS +=		t_select
PROGS +=		t_sendrecv
PROGS +=		t_setuid
PROGS +=		t_sigaction
PROGS +=		t_socketpair
PROGS +=		t_stat
PROGS +=		t_syscall
PROGS +=		t_truncate
PROGS +=		t_umask
PROGS +=		t_unlink
PROGS +=		t_write

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
	${SUDO} rmdir ./dir

.include <bsd.regress.mk>
