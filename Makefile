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

LDADD_t_getpid = 	-lpthread

. for p in ${PROGS}
SRCS_$p = $p.c atf-c.c
. endfor

. for t in ${PROGS}
REGRESS_TARGETS+= run-$t
run-$t: $t
	@echo "\n======== $@ ========"
	@ntests=`${.CURDIR}/$t -n`; \
	echo "1..$$ntests"; \
	for i in `jot - 1 $$ntests`; do \
	    eval `${.CURDIR}/$t -i $$i`; \
	    ${.MAKE} t=$t ATF=$$i \
		"REQ_USER=$$REQ_USER" "DESCR=\"$$DESCR\""; \
	    unset REQ_USER DESCR; \
	done
. endfor

.else # defined(ATF)

CUR_USER!=id -un

. if ${REQ_USER} == "root"
.  if ${CUR_USER} == "root"
REGRESS_TARGETS+= run-$t-${ATF}
REGRESS_CLEANUP+= cleanup-$t-${ATF}
.  elif defined(SUDO)
REGRESS_ROOT_TARGETS+= run-$t-${ATF}
REGRESS_CLEANUP+= cleanup-$t-${ATF}
.  else
REGRESS_SKIP_TARGETS+=run-$t-${ATF}
.  endif

. elif ${REQ_USER} == "nobody"
.  if defined(SUDO) || ${CUR_USER} != "root"
SUDO+= -u ${REQ_USER}
REGRESS_TARGETS+= run-$t-${ATF}
REGRESS_CLEANUP+= cleanup-$t-${ATF}
.  else
REGRESS_SKIP_TARGETS+=run-$t-${ATF}
.  endif

. else # REQ_USER == ""
REGRESS_TARGETS+=run-$t-${ATF}
REGRESS_CLEANUP+= cleanup-$t-${ATF}
. endif

run-$t-${ATF}:
	@echo "${ATF}" ${DESCR}
	@${.CURDIR}/$t -r ${ATF}

cleanup-$t-${ATF}:
	@${.CURDIR}/$t -c ${ATF}

.endif # defined(ATF)

.include <bsd.regress.mk>
