
PRODUCT_ID ?= must_set_directory
PDF_PATH   ?= must_set_pdf_path
TITLE      ?= must_set_title
BLURB      ?= must_set_blurb

all: $(PRODUCT_ID)/index.txt \
  $(PRODUCT_ID)/linkmetadata.json \
  $(PRODUCT_ID)/BookReaderJSSimple.js

$(PRODUCT_ID)/index.txt:
	cp /etc/passwd $@

$(PRODUCT_ID)/linkmetadata.json:
	./generate_link_metadata.sh $(PDF_PATH) $(PRODUCT_ID)

$(PRODUCT_ID)/BookReaderJSSimple.js:
	./example_tgmsbf.sh \
		-c $(PRODUCT_ID) \
		-b '$(TITLE)' \
		-d '$(BLURB)' \
		-i $(PDF_PATH)
