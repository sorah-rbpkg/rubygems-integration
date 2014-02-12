module RubyDebianDev

  SUPPORTED_RUBY_VERSIONS = {
    #name             Ruby binary
    #---------------  -------------------
    'ruby1.9.1' => '/usr/bin/ruby1.9.1',
    'ruby2.0'   => '/usr/bin/ruby2.0',
  }

  RUBY_CONFIG_VERSION = {
    'ruby1.9.1' => '1.9.1',
    'ruby2.0'   => '2.0',
  }

  SUPPORTED_RUBY_SHARED_LIBRARIES = [
    'libruby1.9.1',
    'libruby2.0',
  ]

end
