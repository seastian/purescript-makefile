MAKEFLAGS += --no-builtin-rules -j 3
.SUFFIXES:

OUT_DIR := output
PS_FILES := $(shell fd -e purs -u --exclude node_modules --exclude .spago/g/)

.PHONY: all
all: output/Main/externs.cbor
	@echo building

include $(patsubst %, output/mk/%, $(PS_FILES:.purs=.d))

output/mk/%.d: Makefile %.purs
	@SRC=$*.purs ;\
	MODULE_NAME=$$(rg -e '^module\s([^ ]+)' -or '$$1' $$SRC) ;\
	EXTERNS_FILE=$(OUT_DIR)/$$MODULE_NAME/externs.cbor ;\
	IMPORTS=$$(rg -e '^import\s([^ ]+)' -or '$(OUT_DIR)/$$1/externs.cbor' $$SRC | rg -v '^output/Prim' | sort | uniq) ;\
	mkdir -p $(dir $@) ;\
	echo $$EXTERNS_FILE:  $$SRC $$IMPORTS > $@ ;\
	echo "\t@echo Compiling $$SRC;purs qb server --file $$SRC" >> $@ ;\
	echo >> $@ ;\
	echo .PHONY: $$MODULE_NAME >> $@ ;\
	echo $$MODULE_NAME: $$EXTERNS_FILE >> $@

.PHONY: clean
clean:
	rm -rf $(OUT_DIR)
