.PHONY: all clean pandoc-prereqs

WORKING_DIR := $(shell pwd)
POST_MDS=$(shell find content/posts -name '*.md')
POST_HTMLS=$(patsubst content/posts/%.md,generated/public/posts/%.html,$(POST_MDS))

all: pandoc-prereqs $(POST_HTMLS)

pandoc-prereqs: generated/public/pandoc-highlight.css

generated/public/pandoc-highlight.css: transform/pandoc/templates/highlighting-css.tpl .tool-versions
	@echo "Generating pandoc-highlight.css"
	@mkdir -p $(dir $@)
	@cd transform/pandoc && \
		pandoc -t html5 --template templates/highlighting-css.tpl highlight-dummy.md \
		--metadata title="Dummy" \
		-o $(WORKING_DIR)/generated/public/pandoc-highlight.css

generated/public/posts/%.html: content/posts/%.md transform/pandoc/templates/post.tpl .tool-versions
	@echo "Generating $@"
	@mkdir -p $(dir $@)
	@cd transform/pandoc && \
		pandoc -s -t html5 --template templates/post.tpl $(WORKING_DIR)/$< \
		-o $(WORKING_DIR)/$@

clean:
	@echo "Cleaning generated files"
	@rm -rf generated
