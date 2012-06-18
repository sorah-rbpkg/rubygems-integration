SPECS = $(wildcard spec/*_spec.rb)

test:
	ruby -Ilib $(SPECS)
