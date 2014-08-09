#!/usr/bin/ruby

require File.dirname(__FILE__) + '/../ruby_debian_dev.rb'

%w[
  SUPPORTED_RUBY_VERSIONS
  RUBY_CONFIG_VERSION
  RUBY_API_VERSION
  SUPPORTED_RUBY_SHARED_LIBRARIES
].each do |c|
  puts "#{c}: #{RubyDebianDev.const_get(c)}"
end
