unless ENV['DEBIAN_DISABLE_RUBYGEMS_INTEGRATION']

  class << Gem
    OPERATING_SYSTEM_DEFAULTS = {
      :ssl_ca_cert => '/etc/ssl/certs/ca-certificates.crt'
    }

    alias :upstream_default_dir :default_dir
    def default_dir
      File.join('/', 'var', 'lib', 'gems', RbConfig::CONFIG["ruby_version"])
    end

    alias :upstream_default_bindir :default_bindir
    def default_bindir
      File.join('/', 'usr', 'local', 'bin')
    end

    alias :upstream_default_path :default_path
    def default_path

      arch = RbConfig::CONFIG["arch"]
      api_version = RbConfig::CONFIG["ruby_version"]

      upstream_default_path + [
        "/usr/lib/ruby/gems/#{api_version}",
        File.join('/usr/share/rubygems-integration', api_version),
        '/usr/share/rubygems-integration/all',
        "/usr/lib/#{arch}/rubygems-integration/#{api_version}",
      ].compact
    end

    def default_specifications_dir
      File.join(Gem.upstream_default_dir, "specifications", "default")
    end
  end

  if RUBY_VERSION >= '2.1' and RUBY_VERSION < '2.7' then
    class << Gem::BasicSpecification
      alias :upstream_default_specifications_dir :default_specifications_dir
      def default_specifications_dir
        Gem.default_specifications_dir
      end
    end
  end

end
