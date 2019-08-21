#	$OpenBSD$

# run regression test number i of program t.
# run all tests if i is not defined

.if defined(i)

REQ_USER!= eval `./$t -i $i`; echo $$REQ_USER
DESCR!= eval `./$t -i $i`; echo $$DESCR

. if ${REQ_USER} == "root"
REGRESS_ROOT_TARGETS+= run-$t-$i
. endif

CUR_USER!=id -g
REGRESS_TARGETS+= run-$t-$i

run-$t-$i:
	@echo "${DESCR}"
. if ${REQ_USER} == "root"
	${SUDO} ./$t -r $i
. elif ${REQ_USER} == "unprivileged" && ${CUR_USER} == 0
	${SUDO} su ${BUILDUSER} -c exec ./$t -r $i
. else # REQ_USER == ""
	./$t -r $i
. endif

. if $t == "t_truncate" && $i == "4"
setup-t_truncate:
.  if ${CUR_USER} == 0
	@${SUDO} touch ./truncate_test.root_owned
	@${SUDO} chown root:wheel ./truncate_test.root_owned
.  else
	@echo SKIPPED
.  endif

REGRESS_SETUP_ONCE += setup-t_truncate
. endif

.else
. include "Makefile.progs"
.endif

.include <bsd.regress.mk>
