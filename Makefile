TARGET_EXEC:=zelda3
ROM:=tables/zelda3.sfc
SRCS:=$(wildcard *.c snes/*.c) third_party/gl_core/gl_core_3_1.c third_party/opus-1.3.1-stripped/opus_decoder_amalgam.c
OBJS:=$(SRCS:%.c=%.o)
PYTHON:=/usr/bin/env python3
CFLAGS:=$(if $(CFLAGS),$(CFLAGS),-O2 -Werror)
CFLAGS:=${CFLAGS} $(shell sdl2-config --cflags) -DSYSTEM_VOLUME_MIXER_AVAILABLE=0

ifeq (${OS},Windows_NT)
    WINDRES:=windres
    RES:=zelda3.res
    SDLFLAGS:=-Wl,-Bstatic $(shell sdl2-config --static-libs)
else
    SDLFLAGS:=$(shell sdl2-config --libs) -lm
endif

.PHONY: all clean clean_obj clean_gen

all: $(TARGET_EXEC) tables/zelda3_assets.dat
$(TARGET_EXEC): $(OBJS) $(RES)
	$(CC) $^ -o $@ $(LDFLAGS) $(SDLFLAGS)
%.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@

$(RES): platform/win32/zelda3.rc
	@echo "Generating Windows resources"
	@$(WINDRES) $< -O coff -o $@

tables/zelda3_assets.dat: tables/dialogue.txt
	@echo "Compiling game resources"
	@cd tables; $(PYTHON) compile_resources.py ../$(ROM)
tables/dialogue.txt:
	@echo "Extracting game resources"
	@cd tables; $(PYTHON) extract_resources.py ../$(ROM)

clean: clean_obj clean_gen
clean_obj:
	@$(RM) $(OBJS) $(TARGET_EXEC)
clean_gen:
	@$(RM) $(RES) tables/zelda3_assets.dat tables/*.txt tables/*.png tables/sprites/*.png tables/*.yaml tables/*.patched
	@rm -rf tables/__pycache__ tables/dungeon tables/img tables/overworld tables/sound
