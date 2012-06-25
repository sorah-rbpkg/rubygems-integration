require 'rubygems'
require 'minitest/autorun'
require 'rbconfig'
require 'rubygems/defaults/operating_system'

$RUBY_VERSION = RbConfig::CONFIG['ruby_version']

class RubygemsIntegrationSpec < MiniTest::Spec
  it 'puts gems in /var/lib/gems/VERSION by default' do
    Gem.default_dir.must_equal '/var/lib/gems/' + $RUBY_VERSION
  end

  it 'puts programs in /usr/local/bin' do
    Gem.default_bindir.must_equal '/usr/local/bin'
  end

  it 'includes /usr/share/rubygems-integration/VERSION in Gem.path' do
    Gem.default_path.must_include '/usr/share/rubygems-integration/' + $RUBY_VERSION
  end
end
