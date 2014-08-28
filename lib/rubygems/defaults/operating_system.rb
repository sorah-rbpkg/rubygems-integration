unless ENV['DEBIAN_DISABLE_RUBYGEMS_INTEGRATION']

require 'etc'

class << Gem

  alias :upstream_default_dir :default_dir
  def default_dir
    if Etc.getpwuid.uid == 0
      File.join('/', 'var', 'lib', 'gems', Gem::ConfigMap[:ruby_version])
    else
      user_dir
    end
  end

  alias :upstream_default_bindir :default_bindir
  def default_bindir
    if Etc.getpwuid.uid == 0
      File.join('/', 'usr', 'local', 'bin')
    else
      File.join(user_dir, 'bin')
    end
  end

  alias :upstream_default_path :default_path
  def default_path
    extra_path = nil
    if RbConfig::CONFIG['ruby_version'] == '2.1.0'
      extra_path = File.join('/usr/share/rubygems-integration', '2.1')
    end

    upstream_default_path + [
      File.join('/', 'var', 'lib', 'gems', Gem::ConfigMap[:ruby_version]),
      File.join('/usr/share/rubygems-integration', Gem::ConfigMap[:ruby_version]),
      extra_path,
      '/usr/share/rubygems-integration/all'
    ].compact.uniq
  end

end

if RUBY_VERSION >= '2.0' then
  class << Gem::Specification

    alias :upstream_default_specifications_dir :default_specifications_dir
    def default_specifications_dir
      File.join(Gem.upstream_default_dir, "specifications", "default")
    end

  end
end

end
