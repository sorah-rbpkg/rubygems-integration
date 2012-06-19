class << Gem

  def default_dir
    File.join('/', 'var', 'lib', 'gems', Gem::ConfigMap[:ruby_version])
  end

  def default_bindir
    File.join('/', 'usr', 'local', 'bin')
  end

  alias :upstream_default_path :default_path
  def default_path
    upstream_default_path + [File.join('/usr/share/rubygems-integration', Gem::ConfigMap[:ruby_version])]
  end

end
