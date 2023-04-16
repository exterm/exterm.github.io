WORKING_DIR := $(shell pwd)
.PHONY: pandoc-prereqs clean

pandoc-prereqs: generated/public/pandoc-highlight.css

generated/public/pandoc-highlight.css: transform/pandoc/templates/highlighting-css.tpl .tool-versions
	@echo "Generating pandoc-highlight.css"
	@cd transform/pandoc && \
		pandoc -t html5 --template templates/highlighting-css.tpl highlight-dummy.md \
		--metadata title="Dummy" \
		-o $(WORKING_DIR)/generated/public/pandoc-highlight.css

clean:
	@echo "Cleaning generated files"
	@rm -rf generated/*
	@mkdir -p generated/public
	@touch generated/public/.gitkeep
