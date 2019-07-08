PROGS +=		t_access
PROGS +=		t_bind
PROGS +=		t_chroot
PROGS +=		t_clock_gettime
PROGS +=		t_dup
PROGS +=		t_fsync
PROGS +=		t_getgroups
PROGS +=		t_getitimer

.for p in ${PROGS}
SRCS_$p = $p.c atf-c.c
.endfor

.for t in ${PROGS}
REGRESS_TARGETS+= run-$t
run-$t: $t
	@echo "\n======== $@ ========"
	./$t
.endfor

.include <bsd.regress.mk>
