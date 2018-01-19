#
# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#
DESTDIR         = /
SHARE           = $(DESTDIR)/usr/share/oss/
TOPACKAGE       = Makefile etc plugins sbin  setup tools templates README.md
VERSION         = $(shell test -e ../VERSION && cp ../VERSION VERSION ; cat VERSION)
RELEASE         = $(shell cat RELEASE )
NRELEASE        = $(shell echo $(RELEASE) + 1 | bc )
REQPACKAGES     = $(shell cat REQPACKAGES)
HERE            = $(shell pwd)
PACKAGE         = oss-base

install:
	for i in $(REQPACKAGES); do \
	    rpm -q --quiet $$i || { echo "Missing Required Package $$i"; exit 1; } \
	done  
	mkdir -p $(SHARE)/{setup,templates,tools,plugins}
	mkdir -p $(DESTDIR)/usr/sbin/ 
	mkdir -p $(DESTDIR)/var/adm/fillup-templates/
	mkdir -p $(DESTDIR)/etc/YaST2/
	mkdir -p $(DESTDIR)/usr/lib/systemd/system/
	install -m 755 sbin/*       $(DESTDIR)/usr/sbin/
	rsync -a   etc/             $(DESTDIR)/etc/
	rsync -a   templates/       $(SHARE)/templates/
	rsync -a   setup/           $(SHARE)/setup/
	rsync -a   plugins/         $(SHARE)/plugins/
	rsync -a   tools/           $(SHARE)/tools/
	find $(SHARE)/plugins/ $(SHARE)/tools/ -type f -exec chmod 755 {} \;	
	install -m 644 setup/schoolserver $(DESTDIR)/var/adm/fillup-templates/sysconfig.schoolserver
	install -m 644 setup/oss-firstboot.xml $(DESTDIR)/etc/YaST2/
	install -m 644 setup/oss_salt_event_watcher.service $(DESTDIR)/usr/lib/systemd/system/

dist:
	if [ -e $(PACKAGE) ] ;  then rm -rf $(PACKAGE) ; fi   
	mkdir $(PACKAGE)
	for i in $(TOPACKAGE); do \
	    cp -rp $$i $(PACKAGE); \
	done
	find $(PACKAGE) -type f > files;
	tar jcpf $(PACKAGE).tar.bz2 -T files;
	rm files
	rm -rf $(PACKAGE)
	sed    's/@VERSION@/$(VERSION)/'  $(PACKAGE).spec.in > $(PACKAGE).spec
	sed -i 's/@RELEASE@/$(NRELEASE)/' $(PACKAGE).spec
	if [ -d /data1/OSC/home\:varkoly\:OSS-4-0/$(PACKAGE) ] ; then \
	    cd /data1/OSC/home\:varkoly\:OSS-4-0/$(PACKAGE); osc up; cd $(HERE);\
	    mv $(PACKAGE).tar.bz2 $(PACKAGE).spec /data1/OSC/home\:varkoly\:OSS-4-0/$(PACKAGE); \
	    cd /data1/OSC/home\:varkoly\:OSS-4-0/$(PACKAGE); \
	    osc vc; \
	    osc ci -m "New Build Version"; \
	fi
	echo $(NRELEASE) > RELEASE
	git commit -a -m "New release"
	git push

package:        dist
	rm -rf /usr/src/packages/*
	cd /usr/src/packages; mkdir -p BUILDROOT BUILD SOURCES SPECS SRPMS RPMS RPMS/athlon RPMS/amd64 RPMS/geode RPMS/i686 RPMS/pentium4 RPMS/x86_64 RPMS/ia32e RPMS/i586 RPMS/pentium3 RPMS/i386 RPMS/noarch RPMS/i486
	cp $(PACKAGE).tar.bz2 /usr/src/packages/SOURCES
	rpmbuild -ba $(PACKAGE).spec
	for i in `ls /data1/PACKAGES/rpm/noarch/$(PACKAGE)* 2> /dev/null`; do rm $$i; done
	for i in `ls /data1/PACKAGES/src/$(PACKAGE)* 2> /dev/null`; do rm $$i; done
	cp /usr/src/packages/SRPMS/$(PACKAGE)-*.src.rpm /data1/PACKAGES/src/
	cp /usr/src/packages/RPMS/noarch/$(PACKAGE)-*.noarch.rpm /data1/PACKAGES/rpm/noarch/
	createrepo -p /data1/PACKAGES/

backupinstall:
	for i in $(REQPACKAGES); do \
	    rpm -q --quiet $$i || { echo "Missing Required Package $$i"; exit 1; } \
	    done  
	for i in $(SUBDIRS); do \
	    cd $$i; \
	    make backupinstall DESTDIR=$(DESTDIR) SHARE=$(SHARE); \
	    cd ..;\
	done

restore:
	for i in $(SUBDIRS); do \
	    cd $$i; \
	    make restore; \
	    cd .. ;\
	done

state:
	for i in $(SUBDIRS); do \
	    cd $$i; \
	    make state DESTDIR=$(DESTDIR) SHARE=$(SHARE); \
	    cd .. ;\
	done
