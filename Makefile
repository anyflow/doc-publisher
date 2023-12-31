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
	-t ${REGISTRY_PREFIX_DOC_PUBLISHER}/doc-publisher:${GIT_TAG} \
	-f ./Dockerfile .

# Need GIT_TAG
build_image: BUILD_IMAGE_OPTION=--load
build_image: handle_image

# Need GIT_TAG
push_image: BUILD_IMAGE_OPTION=--push
push_image: handle_image

INPUT_SAMPLES_PATH := ${PWD}/input_samples
TEMPLATES_PATH := ${PWD}/templates
OUTPUT_PATH := ${PWD}/output


generate_all: _prepare
	@python src/__main__.py \
		-im ${INPUT_SAMPLES_PATH}/changelog/CHANGELOG.md \
		-om ${OUTPUT_PATH}/changelog \
		-io ${INPUT_SAMPLES_PATH}/openapi \
		-oo ${OUTPUT_PATH}/openapi && \
	echo ${CYAN}"Generation a html of a markdown completed"${COLOR_OFF}

generate_markdown: _prepare
	@python src/__main__.py \
		-im ${INPUT_SAMPLES_PATH}/changelog/CHANGELOG.md \
		-om ${OUTPUT_PATH}/changelog && \
	echo ${CYAN}"Generation a html of a markdown completed"${COLOR_OFF}

generate_openapis: _prepare
	@python src/__main__.py \
		-io ${INPUT_SAMPLES_PATH}/openapi \
		-oo ${OUTPUT_PATH} && \
	echo ${CYAN}"Generation swagger, redoc of the openapis completed"${COLOR_OFF}

_prepare:
	@rm -rf ${OUTPUT_PATH} && \
	mkdir ${OUTPUT_PATH} && \
	mkdir ${OUTPUT_PATH}/changelog && \
	mkdir ${OUTPUT_PATH}/openapi && \
	echo ${CYAN}"output directory prepared"${COLOR_OFF}

.PHONY: all
all:
.PHONY: clean
clean:
