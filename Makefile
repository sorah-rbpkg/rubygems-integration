SPECS = $(wildcard spec/*_spec.rb)

all:
	@echo Nothing to build!

run-specs:
	ruby -Ilib $(SPECS)

install:
	install -m 755 -d $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults
	install -m 644 lib/rubygems/defaults/operating_system.rb $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults

uninstall:
	$(RM) $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults/operating_system.rb
	rmdir $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults || true
	rmdir $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems || true

clean:
	@echo Nothing to clean
