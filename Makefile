.PHONY: all clean pandoc-prereqs show

WORKING_DIR := $(shell pwd)
POST_MDS=$(shell find content/posts -name '*.md')
POST_HTMLS=$(patsubst content/posts/%.md,generated/public/posts/%.html,$(POST_MDS))
PAGE_MDS=$(shell find content/pages -name '*.md')
PAGE_HTMLS=$(patsubst content/pages/%.md,generated/public/pages/%.html,$(PAGE_MDS))
SOURCE_POST_ASSETS=$(shell find content/posts/assets -type f ! -name '.*')
TARGET_POST_ASSETS=$(patsubst content/%,generated/public/%,$(SOURCE_POST_ASSETS))
TIMESTAMP=$(shell date +%s)

all: pandoc-prereqs $(POST_HTMLS) $(TARGET_POST_ASSETS) $(PAGE_HTMLS) generated/public/index.html generated/public/main.css generated/public/sitemap.xml generated/public/rss.xml

pandoc-prereqs: generated/public/pandoc-highlight.css

show: all
	xdg-open generated/public/index.html

generated/public/pandoc-highlight.css: transform/pandoc/templates/highlighting-css.tpl .tool-versions
	@echo "Generating pandoc-highlight.css"
	@mkdir -p $(dir $@)
	@cd transform/pandoc && \
		pandoc -t html5 --template templates/highlighting-css.tpl highlight-dummy.md \
		--metadata title="Dummy" \
		-o $(WORKING_DIR)/generated/public/pandoc-highlight.css

generated/public/posts/assets/%: content/posts/assets/% .tool-versions
	@echo "Copying asset $< to $@"
	@mkdir -p "$(dir $@)"
	@cp "$<" "$@"

generated/public/posts/%.html: content/posts/%.md transform/pandoc/templates/*.tpl .tool-versions
	@echo "Generating $@"
	@mkdir -p $(dir $@)
	@DATE=$$(echo $< | sed -E 's/.*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/') && \
		cd transform/pandoc && \
		pandoc -s -t html5 --template templates/post.tpl $(WORKING_DIR)/$< \
		-f markdown+smart \
		--lua-filter=link-headers.lua \
		--metadata date="$$DATE" --metadata timestamp=$$TIMESTAMP \
		-o $(WORKING_DIR)/$@

generated/public/pages/%.html: content/pages/%.md transform/pandoc/templates/*.tpl .tool-versions
	@echo "Generating $@"
	@mkdir -p $(dir $@)
	@cd transform/pandoc && \
		pandoc -s -t html5 --template templates/page.tpl $(WORKING_DIR)/$< \
		-f markdown+smart \
		--lua-filter=link-headers.lua \
		--metadata timestamp=$$TIMESTAMP \
		-o $(WORKING_DIR)/$@

generated/public/index.html: transform/pandoc/templates/*.tpl generated/index.md .tool-versions
	@echo "Generating $@"
	@cd transform/pandoc && \
		pandoc -s -t html5 --template templates/index.tpl $(WORKING_DIR)/generated/index.md \
		--metadata title="Simplexity Quest" --metadata timestamp=$$TIMESTAMP \
		-o $(WORKING_DIR)/$@

generated/index.md: $(POST_MDS) transform/render_markdown_index.rb .tool-versions
	@echo "Generating $@"
	@mkdir -p $(dir $@)
	@cd transform && \
		ruby render_markdown_index.rb $(WORKING_DIR)/content/posts $(WORKING_DIR)/$@

generated/public/main.css: main.css
	@echo "Copying main.css to $@"
	@mkdir -p $(dir $@)
	@cp main.css $(WORKING_DIR)/generated/public/main.css

generated/public/sitemap.xml: $(POST_MDS) transform/render_sitemap.rb .tool-versions
	@echo "Generating $@"
	@mkdir -p $(dir $@)
	@cd transform && \
		bundle exec ruby render_sitemap.rb $(WORKING_DIR)/content/posts $(WORKING_DIR)/$@

generated/public/rss.xml: $(POST_MDS) transform/render_rss.rb .tool-versions
	@echo "Generating $@"
	@mkdir -p $(dir $@)
	@cd transform && \
		bundle exec ruby render_rss.rb $(WORKING_DIR)/content/posts $(WORKING_DIR)/$@

clean:
	@echo "Cleaning generated files"
	@rm -rf generated
