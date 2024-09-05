#!/usr/bin/make -f
OUT_DIR ?= docs

export GOBIN := $(shell pwd)/bin
JB_BIN := $(GOBIN)/jb
JSONNET_BIN := $(GOBIN)/jsonnet
SANITIZER_BIN := $(GOBIN)/sanitizer
YQ_BIN := $(GOBIN)/yq

tools := $(JB_BIN) $(JSONNET_BIN) $(SANITIZER_BIN) $(YQ_BIN)
mixins := $(patsubst mixins/%.libsonnet,%,$(wildcard mixins/*.libsonnet))
dashboards: $(addprefix dashboards-, $(mixins))
alerts: $(addprefix prometheusAlerts-, $(mixins))
rules: $(addprefix prometheusRules-, $(mixins))

.DEFAULT_GOAL := all
all: deps dashboards prom
prom: alerts rules

dashboards-%: deps $(tools)
	@echo "Rendering dashboards for $* ..."
	@$(JSONNET_BIN) -J vendor -cm $(OUT_DIR)/$*/dashboards -e '(import "mixins/$*.libsonnet").grafanaDashboards'
	@find $(OUT_DIR)/$*/dashboards -type f -name '*.json' -exec $(YQ_BIN) --inplace --indent 2 --prettyPrint -o json {} \;

prometheus%: deps $(tools)
	$(eval TYPE := $(word 1,$(subst -, ,$@)))
	$(eval MIXIN := $(word 2,$(subst -, ,$@)))
	$(eval TARGET_FILE := $(OUT_DIR)/$(MIXIN)/$(TYPE))
	@echo "Rendering $(TYPE) for $(MIXIN) ..."
	@mkdir -p $(shell dirname $(TARGET_FILE))
	@$(JSONNET_BIN) -J vendor -S -e 'std.manifestYamlDoc((import "mixins/$(MIXIN).libsonnet").$(TYPE))' > $(TARGET_FILE).tmp
	@$(SANITIZER_BIN) $(TARGET_FILE).tmp | tee $(TARGET_FILE).yaml | $(YQ_BIN) --prettyPrint -o json > $(TARGET_FILE).json
	@rm $(TARGET_FILE).tmp

$(tools):
	go install ./cmd/sanitizer
	go install github.com/google/go-jsonnet/cmd/jsonnet@latest
	go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
	go install github.com/mikefarah/yq/v4@latest

.PHONY: deps
deps: $(tools)
	@$(JB_BIN) install

.PHONY: clean
clean:
	@rm -rf $(OUT_DIR)
