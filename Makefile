# Reset
COLOR_OFF="\033[0m"

# Regular Colors
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"

ifndef GIT_TAG
	GIT_TAG := latest
endif

define exit_if_undefined
	@if [ -z "$($1)" ]; then \
		echo "$1 should be defined!"; \
		exit 1; \
	fi
endef

exit_if_git_tag_not_defined:
	$(call exit_if_undefined,GIT_TAG)

.PHONY: test
test: build_manifest

handle_image: exit_if_git_tag_not_defined
	docker buildx build \
	${BUILD_IMAGE_OPTION} \
	--platform linux/amd64 \
	-t ${REGISTRY_PREFIX_MANIFEST_GENERATOR}/manifest-generator:${GIT_TAG} \
	-f ./Dockerfile .

# Need GIT_TAG
build_image: BUILD_IMAGE_OPTION=--load
build_image: handle_image

# Need GIT_TAG
push_image: BUILD_IMAGE_OPTION=--push
push_image: handle_image

MANIFEST_PATH := ${PWD}/manifest_example
APIKEY_PATH := ${PWD}/apikeys.example.yaml
APIKEY_SPEC_PATH := ${PWD}/apikeySpecs.example.yaml
OUTPUT_PATH := ${PWD}/output
VERSION_FOR_TEST := generater_test

check_commitlint:
	$(eval MAIN := $(shell git ls-remote http://mod.lge.com/code/scm/tcn/manifest-generator.git main | cut -f1))
	$(eval COMMON := $(shell git merge-base HEAD $(MAIN)))
	@git log --pretty=format:'%s' --no-merges $(COMMON)^..HEAD | while read -r commit_message; do \
		echo "Checking commit:" ${YELLOW}"$$commit_message"${COLOR_OFF}; \
		echo $$commit_message | npx commitlint || exit 1; \
	done; \
	exit_status=$$?; \
	if [ $$exit_status -ne 0 ]; then \
		echo ${RED}"The branch's commit messages need to be amended!"${COLOR_OFF}; \
		exit 1; \
	else \
		echo ${CYAN}"All commits passed commitlint checks."${COLOR_OFF}; \
	fi


# Should call validate_openapis via ${MAKE}, unless the rules use the old yamls instead of the generated newly
build_manifest: _prepare
	@python src/__main__.py \
		-m ${MANIFEST_PATH} \
		-ak ${APIKEY_PATH} \
		-as ${APIKEY_SPEC_PATH} \
		-v ${VERSION_FOR_TEST} \
		-o ${OUTPUT_PATH} && \
	echo ${CYAN}"Generation openapi.yaml, krakend.yaml, swagger/redoc media completed"${COLOR_OFF}

validate_apigw:
	@python src/__main__.py \
		-c validate_tcn_file \
		-mf ${MANIFEST_PATH}/apigw/base.openapi.yaml

validate_dockebi:
	@python src/__main__.py \
		-c validate_tcn_file \
		-mf ${MANIFEST_PATH}/dockebi/base.openapi.yaml

_prepare:
	@rm -rf ${OUTPUT_PATH} && \
	mkdir ${OUTPUT_PATH} &&\
	echo ${CYAN}"output directory prepared"${COLOR_OFF}

.PHONY: all
all:
.PHONY: clean
clean:
