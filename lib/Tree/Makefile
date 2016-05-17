OBJS = GraphTrack.o GraphTrack_wrap.o
ifeq ($(shell uname),Darwin)
	LDFLAGS = -bundle -flat_namespace -undefined suppress
	SHARED_SUFF = dylib
else
	LDFLAGS = -shared
	SHARED_SUFF = so
endif

ifeq ($(DEBUG),)
	DEBUGFLAGS =
else
	DEBUGFLAGS = -DDEBUG
endif

GraphTrack.$(SHARED_SUFF): $(OBJS)
	ld $(LDFLAGS) $(OBJS) -o GraphTrack.$(SHARED_SUFF)

GraphTrack.pm: GraphTrack.i GraphTrack.c
	swig -perl5 GraphTrack.i

install: GraphTrack.$(SHARED_SUFF) GraphTrack.pm
	cp GraphTrack.pm $(LIBDIR)
	cp GraphTrack.$(SHARED_SUFF) $(LIBDIR)/..

clean:
	rm -f GraphTrack.$(SHARED_SUFF)
	rm -f GraphTrack.pm
	rm -f GraphTrack_wrap.c
	rm -f $(OBJS)

GraphTrack_wrap.c: GraphTrack.pm

%.o: %.c
	gcc $(DEBUGFLAGS) -c -fPIC $< `perl -MExtUtils::Embed -e ccopts`
