- use pandoc to render HTML
  - for reference, https://www.arthurkoziel.com/convert-md-to-html-pandoc/
  - code highlighting: https://stackoverflow.com/questions/62774695/pandoc-where-are-css-files-for-syntax-highlighting-code
- makefiles for incremental build
- collect metadata
  - `pandoc --template=transform/pandoc/templates/metadata.tpl TEST.md | jq '.title,.date'`

Alternative: https://gohugo.io/

## TO DO
- [ ] `publish` script that takes a draft as argument
  - [ ] copies `content/drafts/something.md` to `content/posts/YYYY-MM-DD-something.md`
  - [ ] regenerates blog via Makefile, including the index (via metadata)
- [ ] Serve everything from the `doc` folder (look up in github) so that we don't have "generated" in the url.
  - URLs should be /indext.html and /posts/post-name.html
