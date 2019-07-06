PROGS +=		t_access
PROGS +=		t_bind
PROGS +=		t_chroot

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
