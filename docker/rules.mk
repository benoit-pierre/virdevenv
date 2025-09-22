.DEFAULT: usage
.SILENT:

DRY_RUN := $(findstring n,$(firstword -$(MAKEFLAGS)))

BUILDER ?= docker
REGISTRY ?= docker.io
PLATFORM ?=

define DOCKERFILE
# Automatically generated, do not edit!

# PRE {{{

ARG BASE=scratch
FROM $${BASE} AS build
ARG USER WORKDIR

# }}}

# $< {{{

$(file <$1)

# }}}

# POST {{{

USER 0
$(IMAGE_POST_CLEANUP)
FROM scratch AS final
COPY --from=build / /
ARG USER WORKDIR
USER $${USER}
WORKDIR $${WORKDIR}

# }}}

CMD $(or $(IMAGE_CMD),$(call to_json_array,$(IMAGE_SHELL)))

# vim: foldmethod=marker foldlevel=0 sw=4
endef

IMAGES = $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))
IMAGE_IDS =
BASE_IDS =

PHONIES = all ci-matrix ci-matrix/ prune

# Docker support. {{{

define docker_build
docker build
endef

# }}}

# Podman support. {{{

define podman_build
buildah build --format=docker --layers
endef

# }}}

# Image rules. {{{

platform_arg = $(if $(PLATFORM),--platform $(PLATFORM))

define image_build
	$($(BUILDER)_build)
	$(platform_arg)
	--build-arg REGISTRY=$(REGISTRY) --build-arg BASE=$(IMAGE_BASE)
	--build-arg USER=$(IMAGE_USER) --build-arg WORKDIR=$(IMAGE_WORKDIR)
	$(patsubst %,--build-arg %,$(strip $(BUILD_ARGS)))
	-t $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)
	--progress plain
	--file
endef

comma = ,
shell_escape = '$(subst ','\'',$1)'
to_json_array = [$(patsubst %,"%"$(comma),$(wordlist 2,$(words $1),1 $1)) "$(lastword $1)"]

define image_rules
$(eval IMAGE := $1)
$(eval VERSION := )
$(foreach v,BUILD_ARGS IMAGE_BASE IMAGE_CMD IMAGE_PLATFORM IMAGE_POST_CLEANUP IMAGE_SHELL IMAGE_USER IMAGE_WORKDIR,
$(eval $v := $$(DEFAULT_$v))
)
$(eval include $1/settings.mk)
$(foreach v,IMAGE_BASE IMAGE_PLATFORM IMAGE_SHELL VERSION,
ifeq (,$$($v))
$$(error $1: $v not defined)
endif
)

$1_DOCKERFILE := $$(call DOCKERFILE,$1/Dockerfile)

build/$1.dockerfile: | build/
ifneq (,$$(DRY_RUN))
	$$(info cat >$$@ <<'DOCKERFILE_EOF'$$(newline)$$($1_DOCKERFILE)$$(newline)DOCKERFILE_EOF)
else
	$$(file >$$@,$$($1_DOCKERFILE))
endif

$(eval id = $(subst :,\:,$(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)))
$(eval base_id = $(subst :,\:,$(IMAGE_BASE)))

IMAGE_IDS += $(id)
BASE_IDS += $(base_id)

$(id) $1 $1/: build/$1.dockerfile
	$(strip $(call image_build,$1)) $$< .

ci-matrix/$(IMAGE) ci-matrix/$(id): ci-matrix/$(base_id)
	regctl image digest $(id) 1>&2 || printf '%s' '{ "id": "$(IMAGE) $(VERSION)", "image": "$(subst \:,:,$(id))", "base": "$(IMAGE_BASE)", "platform": "$(subst ",\",$(subst $(empty) $(empty),,$(call to_json_array,$(IMAGE_PLATFORM))))" }, '

$1/inspect:
	$(BUILDER) image inspect $(platform_arg) $(id) | jq --sort-keys

ifeq (docker,$(BUILDER))
$1/latest:
	$(BUILDER) buildx imagetools create $(id) --tag $(REGISTRY)/$(USER)/$1:latest
endif

$(id)/push $1/push:
	$(BUILDER) push $(platform_arg) $(id)

$(id)/run $1/run:
	$(BUILDER) run $(platform_arg) --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(id)

$(eval tar = $(id).tar)

$(id)/save $1/save:
	mkdir -p $(dir $(or $(TAR),$(tar)))
	$(BUILDER) save $(platform_arg) --output '$(or $(TAR),$(tar))' $(id)

$(id)/shell $1/shell:
	$(BUILDER) run $(platform_arg) --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(id) $(IMAGE_SHELL)

PHONIES += $1 $(id) $(foreach p,$(id)/ $1/,$(addprefix $p,inspect push run save shell latest)) build/$1.dockerfile ci-matrix/$(IMAGE) ci-matrix/$(id)

endef

# }}}

# Usage. {{{

define newline


endef

define USAGE
TARGETS:
	make IMAGE            build image
	make IMAGE/inspect    inspect image
	make IMAGE/run        run image
	make IMAGE/shell      run interactive shell in image
	make IMAGE/push       push image to registry
	make IMAGE/save       save image to tar
	make IMAGE/lastest    tag image version has latest (docker only)
	make prune            prune dangling images
	make ci-matrix        output CI build matrix

VARIABLES:
	USER                  repository name (e.g. koreader, default: $(USER))
	REGISTRY              remote registry to push too (default: $(REGISTRY))
	PLATFORM              platform to build the image for (default: current system)

IMAGES:$(foreach i,$(IMAGES),$(newline)	$(i))
endef

usage:
	$(info $(USAGE))

# }}}

prune:
	$(BUILDER) system prune -f

build/:
	mkdir -p $@

$(foreach i,$(IMAGES),$(eval $(call image_rules,$i)))

ci-matrix ci-matrix/: $(foreach t,$(IMAGE_IDS),ci-matrix/$t)

$(foreach t,$(filter-out $(IMAGE_IDS),$(BASE_IDS)),ci-matrix/$t):

.PHONY: $(PHONIES)

# vim: foldmethod=marker foldlevel=0
