PROGS +=		t_access
PROGS +=		t_bind

.for t in ${PROGS}
REGRESS_TARGETS+= run-$t
run-$t: $t
	@echo "\n======== $@ ========"
	./$t
.endfor

.include <bsd.regress.mk>
