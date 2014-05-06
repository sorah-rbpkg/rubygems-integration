module RubyDebianDev

  SUPPORTED_RUBY_VERSIONS = {
    #name             Ruby binary
    #---------------  -------------------
    'ruby2.1'   => '/usr/bin/ruby2.1',
  }

  RUBY_CONFIG_VERSION = {
    'ruby2.1'   => '2.1',
  }

  RUBY_API_VERSION = {
    'ruby2.1'   => '2.1.0',
  }

  SUPPORTED_RUBY_SHARED_LIBRARIES = [
    'libruby2.1',
  ]

end
