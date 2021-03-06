#Makefiles
TERRAFORM=aws/terraform
NAVIGATE_HANDBOOK=github/navigate-handbook
SEARCH_HANDBOOK=github/search-handbook
SC_COFFEE_GO=scaffold/coffee-go
SC_SPRING_STARTER=scaffold/spring-starter
KAFKA=kafka
DOCKER=docker/compose
KUBERNETES=kubernetes/core
FAST_MERGE=github/fast-merge
FORMULAS=$(TERRAFORM) $(SC_COFFEE_GO) $(SC_SPRING_STARTER) $(KAFKA) $(DOCKER) $(NAVIGATE_HANDBOOK) $(SEARCH_HANDBOOK) $(KUBERNETES) $(FAST_MERGE)

PWD_INITIAL=$(shell pwd)

FORM_TO_UPPER  = $(shell echo $(form) | tr  '[:lower:]' '[:upper:]')
FORM = $($(FORM_TO_UPPER))

push-s3:
	echo $(RITCHIE_AWS_BUCKET)
	echo "Init pwd: $(PWD_INITIAL)"
	for formula in $(FORMULAS); do cd $$formula/src && make build && cd $(PWD_INITIAL) || exit; done
	./copy-bin-configs.sh "$(FORMULAS)"
	aws s3 cp . s3://$(RITCHIE_AWS_BUCKET)/ --exclude "*" --include "formulas/*" --recursive
	aws s3 cp . s3://$(RITCHIE_AWS_BUCKET)/ --exclude "*" --include "tree/tree.json" --recursive
	rm -rf formulas

bin:
	echo "Init pwd: $(PWD_INITIAL)"
	echo "Formulas bin: $(FORMULAS)"
	for formula in $(FORMULAS); do cd $$formula/src && make build && cd $(PWD_INITIAL); done
	./copy-bin-configs.sh "$(FORMULAS)"

test-local:
ifneq ("$(FORM)", "")
	@echo "Using form true: "  $(FORM_TO_UPPER)
	$(MAKE) bin FORMULAS=$(FORM)
	mkdir -p ~/.rit/formulas
	rm -rf ~/.rit/formulas/$(FORM)
	./unzip-bin-configs.sh
	cp -r formulas/* ~/.rit/formulas
	rm -rf formulas
else
	@echo "Use make test-local form=NAME_FORMULA for specific formula."
	@echo "form false: ALL FORMULAS"
	$(MAKE) bin
	rm -rf ~/.rit/formulas
	./unzip-bin-configs.sh
	mv formulas ~/.rit
endif
	mkdir -p ~/.rit/repo/local
	rm -rf ~/.rit/repo/local/tree.json
	cp tree/tree.json  ~/.rit/repo/local/tree.json

