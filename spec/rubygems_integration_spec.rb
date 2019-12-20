# frozen_string_literal: true

require 'rubygems'
require 'minitest/autorun'
require 'rbconfig'
require 'rubygems/defaults/operating_system'

$RUBY_VERSION = RbConfig::CONFIG['ruby_version']
$ARCH = RbConfig::CONFIG['arch']

class RubygemsIntegrationSpec < MiniTest::Spec
  it 'puts gems in /var/lib/gems/VERSION by default' do
    _(Gem.default_dir).must_equal '/var/lib/gems/' + RUBY_VERSION
  end

  it 'does not remove /usr/lib/ruby/gems/VERSION from gem path' do
    _(Gem.default_path).must_include "/usr/lib/ruby/gems/#{RUBY_VERSION}"
  end

  it 'puts programs in /usr/local/bin' do
    _(Gem.default_bindir).must_equal '/usr/local/bin'
  end

  it 'includes /usr/share/rubygems-integration/VERSION in Gem.path' do
    path = Gem.default_path
    _(path).must_include '/usr/share/rubygems-integration/' + RUBY_VERSION
  end

  it 'includes /usr/lib/ARCH/rubygems-integration/VERSION in Gem.path' do
    path = Gem.default_path
    _(path).must_include "/usr/lib/#{ARCH}/rubygems-integration/#{RUBY_VERSION}"
  end
end
