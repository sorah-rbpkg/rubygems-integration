require 'minitest/autorun'

class RubygemsIntegrationSpec < MiniTest::Spec
  ARCH = RbConfig::CONFIG['arch']
  RUBY_API_VERSION = RbConfig::CONFIG['ruby_version']

  it 'puts gems in /var/lib/gems/VERSION by default' do
    _(Gem.default_dir).must_equal '/var/lib/gems/' + RUBY_API_VERSION
  end

  it 'does not remove /usr/lib/ruby/gems/VERSION from gem path' do
    _(Gem.default_path).must_include "/usr/lib/ruby/gems/#{RUBY_API_VERSION}"
  end

  it 'puts programs in /usr/local/bin' do
    _(Gem.default_bindir).must_equal '/usr/local/bin'
  end

  it 'includes user dir first in default path' do
    _(Gem.default_path[0]).must_equal Gem.user_dir
  end

  it 'includes the default dir in the default path' do
    _(Gem.default_path).must_include Gem.default_dir
  end

  it 'includes /usr/lib/ruby/gems/VERSION the default path' do
    _(Gem.default_path).must_include "/usr/lib/ruby/gems/#{RUBY_API_VERSION}"
  end

  it 'includes /usr/local/lib/ruby/gems/VERSION the default path' do
    _(Gem.default_path).must_include "/usr/local/lib/ruby/gems/#{RUBY_API_VERSION}"
  end

  it 'includes gem dir under multiarch libdir in default path' do
    _(Gem.default_path).must_include "/usr/lib/#{ARCH}/ruby/gems/#{RUBY_API_VERSION}"
  end

  it 'includes /usr/share/rubygems-integration/VERSION in Gem.path' do
    path = Gem.default_path
    _(path).must_include '/usr/share/rubygems-integration/' + RUBY_API_VERSION
  end

  it 'includes /usr/lib/ARCH/rubygems-integration/VERSION in Gem.path' do
    path = Gem.default_path
    _(path).must_include "/usr/lib/#{ARCH}/rubygems-integration/#{RUBY_API_VERSION}"
  end
end
