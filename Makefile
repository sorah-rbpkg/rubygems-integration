RUBY = ruby
SPECS = $(wildcard spec/*_spec.rb)

all:
	@echo Nothing to build!

.PHONY: spec

spec:
	$(RUBY) -Ilib $(SPECS)

install:
	install -m 755 -d $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults
	install -m 644 lib/rubygems/defaults/operating_system.rb $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults

uninstall:
	$(RM) $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults/operating_system.rb
	rmdir -p $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults

clean:
	@echo Nothing to clean
