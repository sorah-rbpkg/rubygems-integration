RUBIES = $(shell ruby -rruby_debian_dev -e "puts RubyDebianDev::SUPPORTED_RUBY_VERSIONS.keys.join(' ')")
SPEC_ON_ALL_RUBIES = $(patsubst %, spec-%, $(RUBIES))
ifeq (,$(AUTOPKGTEST_TMP))
	LIB := -Ilib
endif

all:
	@echo Nothing to build!

.PHONY: spec $(SPEC_ON_ALL_RUBIES)

spec: $(SPEC_ON_ALL_RUBIES)
	@echo $(SPEC_ON_ALL_RUBIES)

$(SPEC_ON_ALL_RUBIES): spec-%:
	$* -w $(LIB) spec/rubygems_integration_spec.rb

install:
	install -m 755 -d $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults
	install -m 644 lib/rubygems/defaults/operating_system.rb $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults

uninstall:
	$(RM) $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults/operating_system.rb
	rmdir -p $(DESTDIR)/usr/lib/ruby/vendor_ruby/rubygems/defaults

clean:
	@echo Nothing to clean
