module RubyDebianDev

  RUBY_INTERPRETERS = {}

  def self.has_support_for(ruby)
    RUBY_INTERPRETERS[ruby] = yield
  end

  has_support_for 'ruby2.3' do
    {
      version:             '2.3',
      binary:              '/usr/bin/ruby2.3',
      api_version:         '2.3.0',
      shared_library:      'libruby2.3',
      min_ruby_dependency: 'ruby (>= 1:2.3~0)',
    }
  end

  has_support_for 'ruby2.5' do
    {
      version:             '2.5',
      binary:              '/usr/bin/ruby2.5',
      api_version:         '2.5.0',
      shared_library:      'libruby2.5',
      min_ruby_dependency: 'ruby (>= 1:2.5~0)',
    }
  end

  def self.min_ruby_dependency_for(shared_library)
    RUBY_INTERPRETERS.each do |int,data|
      if data[:shared_library] == shared_library
        return data[:min_ruby_dependency]
      end
    end
    return nil
  end

  #################################################################
  # These constants below are kept here for backwards compatibility
  #################################################################
  SUPPORTED_RUBY_VERSIONS = RUBY_INTERPRETERS.keys.inject({}) do |supported,interpreter|
    supported[interpreter] = RUBY_INTERPRETERS[interpreter][:binary]
    supported
  end

  RUBY_CONFIG_VERSION = RUBY_INTERPRETERS.keys.inject({}) do |supported,interpreter|
    supported[interpreter] = RUBY_INTERPRETERS[interpreter][:version]
    supported
  end

  RUBY_API_VERSION = RUBY_INTERPRETERS.keys.inject({}) do |supported,interpreter|
    supported[interpreter] = RUBY_INTERPRETERS[interpreter][:api_version]
    supported
  end

  SUPPORTED_RUBY_SHARED_LIBRARIES = RUBY_INTERPRETERS.map { |k,v| v[:shared_library] }

end
