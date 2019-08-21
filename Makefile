#	$OpenBSD$

# run regression test TEST number NUM
# run all tests in PROGS if NUM is not defined

REGRESS_TARGETS =
REGRESS_ROOT_TARGETS =

.if defined(NUM)

REQ_USER!= eval `./${TEST} -i ${NUM}`; echo $$REQ_USER
DESCR!= eval `./${TEST} -i ${NUM}`; echo $$DESCR

. if ${REQ_USER} == "root"
REGRESS_ROOT_TARGETS +=	run-${TEST}-${NUM}
. endif

CUR_USER!=id -g
REGRESS_TARGETS +=	run-${TEST}-${NUM}

run-${TEST}-${NUM}:
	@echo "${DESCR}"
. if ${REQ_USER} == "root"
	${SUDO} ./${TEST} -r ${NUM}
. elif ${REQ_USER} == "unprivileged" && ${CUR_USER} == 0
	${SUDO} su ${BUILDUSER} -c exec ./${TEST} -r ${NUM}
. elif ${REQ_USER} == "unprivileged" || ${REQ_USER} == ""
	./${TEST} -r ${NUM}
. else
	# bad REQ_USER: ${REQ_USER}
	false
. endif

.else
. include "Makefile.progs"
.endif

.include <bsd.regress.mk>

cleanup-t_chroot:
	${SUDO} rm -rf ./dir

clean: cleanup-t_chroot
