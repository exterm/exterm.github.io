.PHONY: all clean pandoc-prereqs

WORKING_DIR := $(shell pwd)
POST_MDS=$(shell find content/posts -name '*.md')
POST_HTMLS=$(patsubst content/posts/%.md,generated/public/posts/%.html,$(POST_MDS))

all: pandoc-prereqs $(POST_HTMLS) index.html

pandoc-prereqs: generated/public/pandoc-highlight.css

generated/public/pandoc-highlight.css: transform/pandoc/templates/highlighting-css.tpl .tool-versions
	@echo "Generating pandoc-highlight.css"
	@mkdir -p $(dir $@)
	@cd transform/pandoc && \
		pandoc -t html5 --template templates/highlighting-css.tpl highlight-dummy.md \
		--metadata title="Dummy" \
		-o $(WORKING_DIR)/generated/public/pandoc-highlight.css

generated/public/posts/%.html: content/posts/%.md transform/pandoc/templates/*.tpl .tool-versions
	@echo "Generating $@"
	@mkdir -p $(dir $@)
	@DATE=$$(echo $< | sed -E 's/.*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/') && \
		cd transform/pandoc && \
		pandoc -s -t html5 --template templates/post.tpl $(WORKING_DIR)/$< \
		-f markdown+smart \
		--metadata date="$$DATE" --metadata timestamp=$$(date +%s) \
		-o $(WORKING_DIR)/$@

index.html: transform/pandoc/templates/*.tpl generated/index.md .tool-versions
	@echo "Generating $@"
	@cd transform/pandoc && \
		pandoc -s -t html5 --template templates/index.tpl $(WORKING_DIR)/generated/index.md \
		--metadata title="Simplexity Quest" --metadata timestamp=$$(date +%s) \
		-o $(WORKING_DIR)/$@

generated/index.md: $(POST_MDS) transform/render_markdown_index.rb .tool-versions
	@echo "Generating $@"
	@mkdir -p $(dir $@)
	@cd transform && \
		ruby render_markdown_index.rb $(WORKING_DIR)/content/posts $(WORKING_DIR)/$@

clean:
	@echo "Cleaning generated files"
	@rm -rf generated
	@rm -f index.html
