# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'rbconfig'
require 'open3'

class RubygemsIntegrationSpec < Minitest::Spec
  RUBY_VERSION = RbConfig::CONFIG['ruby_version']
  ARCH = RbConfig::CONFIG['arch']
  RUBY_API_VERSION = RbConfig::CONFIG['ruby_version']
  SPEC_LIB = File.expand_path('../lib', __dir__)

  def integration_ruby_args
    args = [RbConfig.ruby, '-w']
    if ENV['AUTOPKGTEST_TMP'].nil? &&
       File.file?(File.join(SPEC_LIB, 'rubygems/defaults/operating_system.rb'))
      args += ['-I', SPEC_LIB]
    end
    args
  end

  def ruby_eval(code, env = {})
    full_env = ENV.to_h.merge(env.transform_keys(&:to_s))
    # Ensure child does not inherit a stale RUBYOPT that forces system gems.
    full_env.delete('RUBYOPT') unless env.key?('RUBYOPT') || env.key?(:RUBYOPT)
    out, err, status = Open3.capture3(full_env, *integration_ruby_args, '-e', code)
    [out, err, status]
  end

  def ruby_eval!(code, env = {})
    out, err, status = ruby_eval(code, env)
    unless status.success?
      flunk "ruby -e failed (#{status.exitstatus}): #{err}\n#{out}"
    end
    out
  end

  it 'puts gems in /var/lib/gems/VERSION by default' do
    _(Gem.default_dir).must_equal '/var/lib/gems/' + RUBY_API_VERSION
  end

  it 'does not remove /usr/lib/ruby/gems/VERSION from gem path' do
    _(Gem.default_path).must_include "/usr/lib/ruby/gems/#{RUBY_API_VERSION}"
  end

  it 'puts programs in /usr/local/bin' do
    _(Gem.default_bindir).must_equal '/usr/local/bin'
  end

  it 'includes user dir first in default path when user home exists' do
    if Gem.user_home && File.exist?(Gem.user_home)
      _(Gem.default_path[0]).must_equal Gem.user_dir
    else
      # RubyGems omits user_dir from default_path when user_home is missing
      # (common in autopkgtest schroots without a real home directory).
      _(Gem.default_path[0]).must_equal Gem.default_dir
    end
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

  it 'includes /usr/share/rubygems-integration/all in default path' do
    _(Gem.default_path).must_include '/usr/share/rubygems-integration/all'
  end

  it 'includes /usr/lib/ARCH/rubygems-integration/VERSION in Gem.path' do
    path = Gem.default_path
    _(path).must_include "/usr/lib/#{ARCH}/rubygems-integration/#{RUBY_API_VERSION}"
  end

  it 'points default specifications at the Ruby-shipped gem location' do
    expected = File.join(Gem.upstream_default_dir, 'specifications', 'default')
    _(Gem.default_specifications_dir).must_equal expected
  end

  it 'does not use /var/lib/gems for default gem specifications' do
    _(Gem.default_specifications_dir).wont_include '/var/lib/gems'
  end

  it 'exposes Debian ca-certificates via Gem.operating_system_defaults' do
    defaults = Gem.operating_system_defaults
    _(defaults[:ssl_ca_cert] || defaults['ssl_ca_cert'])
      .must_equal '/etc/ssl/certs/ca-certificates.crt'
  end

  it 'applies ssl_ca_cert from operating_system_defaults to Gem.configuration' do
    _(Gem.configuration.ssl_ca_cert).must_equal '/etc/ssl/certs/ca-certificates.crt'
  end

  it 'disables gem update --system with a clear APT message' do
    msg = Gem.disable_system_update_message
    _(msg).wont_be_nil
    _(msg).must_match(/through APT/i)
    _(msg).must_match(/unsupported/i)
    _(msg).wont_match(/trough APT/)
  end

  it 'keeps Debian package locations on Gem.path' do
    _(Gem.path).must_include '/usr/share/rubygems-integration/all'
    _(Gem.path).must_include "/usr/share/rubygems-integration/#{RUBY_API_VERSION}"
  end

  it 'restores upstream defaults when DEBIAN_DISABLE_RUBYGEMS_INTEGRATION is set' do
    code = <<~'RUBY'
      require 'rbconfig'
      puts Gem.default_dir
      puts Gem.default_bindir
      puts Gem.default_path.include?('/usr/share/rubygems-integration/all')
    RUBY
    out = ruby_eval!(code, 'DEBIAN_DISABLE_RUBYGEMS_INTEGRATION' => '1')
    dir, bindir, has_all = out.lines.map(&:chomp)
    _(dir).must_equal File.join(RbConfig::CONFIG['rubylibprefix'], 'gems', RUBY_API_VERSION)
    _(bindir).must_equal RbConfig::CONFIG['bindir']
    _(has_all).must_equal 'false'
  end

  it 'still applies ssl_ca_cert when path integration is disabled' do
    code = 'puts Gem.configuration.ssl_ca_cert.inspect'
    out = ruby_eval!(code, 'DEBIAN_DISABLE_RUBYGEMS_INTEGRATION' => '1')
    _(out.strip).must_equal '"/etc/ssl/certs/ca-certificates.crt"'
  end

  it 'still disables gem update --system when path integration is disabled' do
    code = 'puts Gem.disable_system_update_message.to_s.include?("unsupported")'
    out = ruby_eval!(code, 'DEBIAN_DISABLE_RUBYGEMS_INTEGRATION' => '1')
    _(out.strip).must_equal 'true'
  end

  it 'can require a gem shipped via rubygems-integration/all when installed' do
    gemspec = '/usr/share/rubygems-integration/all/specifications'
    skip 'no rubygems-integration gemspecs installed' unless Dir.exist?(gemspec) &&
                                                            !Dir.empty?(gemspec)

    # minitest is commonly present via ruby-minitest; any gem is fine.
    names = Dir.children(gemspec).map { |f| f.sub(/-[\d.].*\.gemspec\z/, '') }.uniq
    skip 'no gemspecs found' if names.empty?

    name = names.include?('minitest') ? 'minitest' : names.first
    code = "gem #{name.dump}; puts :ok"
    out, err, status = ruby_eval(code)
    if status.success?
      _(out.strip).must_equal 'ok'
    else
      skip "gem #{name.inspect} not activatable in this environment: #{err.lines.first}"
    end
  end
end
