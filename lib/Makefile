#export LIBDIR = /home/brown22/libperl
#export BINDIR = /home/brown22/bin

DIRS = Anno \
       IO \
       Seq \
       Struct \
       Synteny \
       Tree

LIBS = Conf.pm \
       Ensembl.pm \
       Util.pm

all:
	-for d in $(DIRS); do ( export LIBDIR=$(LIBDIR)/$$d; cd $$d; $(MAKE) ); done

clean:
	-for d in $(DIRS); do ( export LIBDIR=$(LIBDIR)/$$d; cd $$d; $(MAKE) clean ); done

install:
	mkdir -p $(LIBDIR)
	cp $(LIBS) $(LIBDIR)
	-for d in $(DIRS); do ( mkdir -p $(LIBDIR)/$$d; export LIBDIR=$(LIBDIR)/$$d; cd $$d; $(MAKE) install ); done
