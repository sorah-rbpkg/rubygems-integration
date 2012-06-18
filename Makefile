SPECS = $(wildcard spec/*_spec.rb)

all:
	@echo Nothing to build!

run-specs:
	ruby -Ilib $(SPECS)

install:
	install -d $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems
	install -m 644 lib/rubygems/operating_system.rb $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems

clean:
	@echo Nothing to clean
