PROGS +=		t_access

.for t in ${PROGS}
REGRESS_TARGETS+= run-$t
run-$t: $t
	@echo "\n======== $@ ========"
	./$t
.endfor

.include <bsd.regress.mk>
