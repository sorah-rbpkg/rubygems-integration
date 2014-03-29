module RubyDebianDev

  SUPPORTED_RUBY_VERSIONS = {
    #name             Ruby binary
    #---------------  -------------------
    'ruby2.0'   => '/usr/bin/ruby2.0',
    'ruby2.1'   => '/usr/bin/ruby2.1',
  }

  RUBY_CONFIG_VERSION = {
    'ruby2.0'   => '2.0',
    'ruby2.1'   => '2.1',
  }

  SUPPORTED_RUBY_SHARED_LIBRARIES = [
    'libruby2.0',
    'libruby2.1',
  ]

end
