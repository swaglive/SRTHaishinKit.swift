includedir = build/includes
srcdir = srt/srtcore
SOURCE_HEADERS = $(notdir $(wildcard $(srcdir)/*.h))
TARGET_HEADERS = $(addprefix $(includedir)/,$(SOURCE_HEADERS))

.PHONY: all mkdir headers

all: test mkdir headers

test:
	echo $(SOURCE_HEADERS)

headers: $(TARGET_HEADERS)	

$(TARGET_HEADERS): $(includedir)/%.h: $(srcdir)/%.h
	-cp $? $@

mkdir:
	-mkdir -p $(includedir)
