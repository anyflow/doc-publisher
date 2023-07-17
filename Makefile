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

INPUT_SAMPLES_PATH := ${PWD}/input_samples
TEMPLATES_PATH := ${PWD}/templates
OUTPUT_PATH := ${PWD}/output


# Should call validate_openapis via ${MAKE}, unless the rules use the old yamls instead of the generated newly
generate_markdown: _prepare
	@python src/__main__.py \
		-im ${INPUT_SAMPLES_PATH}/markdown/MANIFEST.md \
		-o ${OUTPUT_PATH} && \
	echo ${CYAN}"Generation a html of a markdown completed"${COLOR_OFF}

_prepare:
	@rm -rf ${OUTPUT_PATH} && \
	mkdir ${OUTPUT_PATH} &&\
	echo ${CYAN}"output directory prepared"${COLOR_OFF}

.PHONY: all
all:
.PHONY: clean
clean:
