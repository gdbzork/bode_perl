export LIBDIR = /home/brown22/libperl
export BINDIR = /home/brown22/bin

DIRS = lib src

all:
	-for d in $(DIRS); do (cd $$d; $(MAKE) ); done

clean:
	-for d in $(DIRS); do (cd $$d; $(MAKE) clean ); done

install:
	-for d in $(DIRS); do (cd $$d; $(MAKE) install ); done

doc:
	perlmod2www.pl  -source lib -target /var/www/html/pdoc -raw -isa
