CONTEXT = cockroachdb
VERSION = v0.10.1
IMAGE_NAME = cockroach
REGISTRY = docker-registry.default.svc.cluster.local:5000
OC_USER=developer
OC_PASS=developer

# Allow user to pass in OS build options
ifeq ($(TARGET),centos7)
	DFILE := Dockerfile.${TARGET}
else
	TARGET := rhel7
	DFILE := Dockerfile
endif

all: build
build:
	docker build --pull -t ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} -t ${CONTEXT}/${IMAGE_NAME} -f ${DFILE} .
	@if docker images ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}; then touch build; fi

lint:
	dockerfile_lint -f Dockerfile
	dockerfile_lint -f Dockerfile.centos7

test:
	$(eval CONTAINERID=$(shell docker run -tdi -u $(shell shuf -i 1000010000-1000020000 -n 1) \
	--cap-drop=KILL \
	--cap-drop=MKNOD \
	--cap-drop=SYS_CHROOT \
	--cap-drop=SETUID \
	--cap-drop=SETGID \
	${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} start --insecure))
	@sleep 3
	@docker exec ${CONTAINERID} curl localhost:8080
	@docker logs ${CONTAINERID}
	@docker rm -f ${CONTAINERID}

openshift-test:
	$(eval PROJ_RANDOM=test-$(shell shuf -i 100000-999999 -n 1))
	oc login -u ${OC_USER} -p ${OC_PASS}
	oc new-project ${PROJ_RANDOM}
	docker login -u ${OC_USER} -p ${OC_PASS} ${REGISTRY}
	docker tag ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} ${REGISTRY}/${PROJ_RANDOM}/${IMAGE_NAME}
	docker push ${REGISTRY}/${PROJ_RANDOM}/${IMAGE_NAME}
	oc run ${IMAGE_NAME} --image=${REGISTRY}/${PROJ_RANDOM}/${IMAGE_NAME} -- start --insecure
	oc rollout status -w dc/${IMAGE_NAME}
	oc expose dc/${IMAGE_NAME} --port=8080
	oc status
	sleep 5
	oc describe pod `oc get pod --template '{{(index .items 0).metadata.name }}'`
	curl `oc get svc/${IMAGE_NAME} --template '{{.spec.clusterIP}}:{{index .spec.ports 0 "port"}}'`
	oc logs dc/${IMAGE_NAME}

run:
	docker run -tdi -u $(shell shuf -i 1000010000-1000020000 -n 1) \
	--hostname="localhost.localdomain" \
	-p 26257:26257 \
	-p 8080:8080 \
	--cap-drop=KILL \
	--cap-drop=MKNOD \
	--cap-drop=SYS_CHROOT \
	--cap-drop=SETUID \
	--cap-drop=SETGID \
	${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} start --insecure

clean:
	rm -f build