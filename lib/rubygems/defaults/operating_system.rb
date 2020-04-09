# frozen_string_literal: true

class << Gem
  OPERATING_SYSTEM_DEFAULTS = {
    ssl_ca_cert: '/etc/ssl/certs/ca-certificates.crt'
  }.freeze
end

if ENV['DEBIAN_RUBY_STANDALONE']
  $LOAD_PATH.reject! do |entry|
    entry =~ /vendor_ruby/
  end

  require 'etc'

  class << Gem

    alias upstream_ruby ruby
    def ruby
      "/usr/lib/ruby-standalone/bin/ruby"
    end

    def __root__?
      Etc.getpwuid.uid == 0
    end

    alias upstream_default_bindir default_bindir
    def default_bindir
      __root__? && '/usr/local/bin' || File.join(Gem.user_dir, 'bin')
    end

    alias upstream_default_dir default_dir
    def default_dir
      __root__? && "/var/lib/gems/#{RUBY_VERSION}" || user_dir
    end

    alias upstream_default_path default_path
    def default_path
      [user_dir, "/var/lib/gems/#{RUBY_VERSION}", "/usr/lib/ruby/gems/#{RUBY_VERSION}"]
    end

    alias upstream_default_specifications_dir default_specifications_dir
    def default_specifications_dir
      "/usr/lib/ruby/gems/#{RUBY_VERSION}/specifications/default"
    end

    alias upstream_user_dir user_dir
    def user_dir
      File.join(Gem.user_home, '.ruby-standalone/gems', Gem.ruby_engine, RUBY_VERSION)
    end
  end

elsif !ENV['DEBIAN_DISABLE_RUBYGEMS_INTEGRATION']

  class << Gem
    alias upstream_default_dir default_dir
    def default_dir
      File.join('/', 'var', 'lib', 'gems', RbConfig::CONFIG['ruby_version'])
    end

    alias upstream_default_bindir default_bindir
    def default_bindir
      File.join('/', 'usr', 'local', 'bin')
    end

    alias upstream_default_path default_path
    def default_path
      arch = RbConfig::CONFIG['arch']
      api_version = RbConfig::CONFIG['ruby_version']

      upstream_default_path + [
        "/usr/local/lib/ruby/gems/#{api_version}",
        "/usr/lib/ruby/gems/#{api_version}",
        "/usr/lib/#{arch}/ruby/gems/#{api_version}",
        File.join('/usr/share/rubygems-integration', api_version),
        '/usr/share/rubygems-integration/all',
        upstream_default_dir,
        "/usr/lib/#{arch}/rubygems-integration/#{api_version}"
      ].compact
    end

    # This was not defined in ruby2.5, and is now defined again in ruby2.7;
    # therefore the alias call must be conditional
    alias :upstream_default_specifications_dir :default_specifications_dir if RUBY_VERSION >= '2.7'
    def default_specifications_dir
      File.join(Gem.upstream_default_dir, 'specifications', 'default')
    end
  end

  if (RUBY_VERSION >= '2.1') && (RUBY_VERSION < '2.7')
    class << Gem::BasicSpecification
      alias upstream_default_specifications_dir default_specifications_dir
      def default_specifications_dir
        Gem.default_specifications_dir
      end
    end
  end

  if RUBY_VERSION >= '2.7'
    class Gem::Specification
      alias :upstream_rubyforge_project= :rubyforge_project=
      def rubyforge_project=(x)
      end
    end
  end

end
