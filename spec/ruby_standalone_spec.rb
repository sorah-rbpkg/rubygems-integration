require 'etc'

class RubyStandaloneSpec
  def self.it(name, &block)
    @tests ||= []
    @tests << ['it ' + name, block]
  end

  class BadTest < Exception
    attr_accessor :name
    attr_accessor :exception
    def initialize(name = nil)
      self.name = name
    end
    def to_s
      "#{fact}: #{name}" + "\n    "  + exception.to_s + "\n\n" + backtrace.map { |l| "    " + l }.join("\n")
    end
    def backtrace
      exception.backtrace
    end
  end

  class Failure < BadTest
    def fact
      "Failed"
    end
    def backtrace
      exception.backtrace[1..-1]
    end
  end
  class Error < BadTest
    def fact
      "Error"
    end
  end
  class FailedAssertion < Exception
  end

  def self.run
    puts unless @tests.empty?
    failures = []
    @tests.shuffle.each do |t|
      name, block = t
      begin
        self.new.instance_eval(&block)
        print '.'
      rescue FailedAssertion => e
        failure = Failure.new(name)
        failure.exception = e
        print 'F'
        failures << failure
      rescue Exception => e
        err = Error.new(name)
        err.exception = e
        print 'E'
        failures << err
      end
    end
    puts

    data = [
      [:tests, @tests.size],
      [:passed, @tests.size - failures.size],
      [:failed, failures.select { |f| Failure === f}.size],
      [:errors, failures.select { |f| Error === f}.size],
    ].select do |k,v|
        v > 0
    end
    puts unless failures.empty?
    failures.each_with_index do |f, i|
      puts "#{i+1}) #{f}"
      puts
    end

    puts
    puts data.map { |k, v| "#{v} #{k}"}.join(', ')
    failures.empty? ? 0 : 1
  end

  def assert_equal(a, b)
    raise FailedAssertion.new("expected #{a.inspect} == #{b.inspect}") unless a == b
    true
  end

  def assert_no_match(a, b)
    raise FailedAssertion.new("expected #{a.inspect} to not match #{b.inspect}") if a =~ b
    true
  end

  RUBY_API_VERSION = RbConfig::CONFIG["ruby_version"]
  USER = Etc.getpwuid.name

  it 'removes all vendor directories from $LOAD_PATH' do
    assert_no_match $LOAD_PATH.join(':'), /vendor_rxuby/
  end

  if Etc.getpwuid.name == 'root'
    it 'installs to /var/lib/gems' do
      Gem.default_dir == "/var/lib/gems/#{RUBY_API_VERSION}"
    end
    it 'installs programs to system PATH' do
      Gem.default_bindir == "/usr/local/bin"
    end
  else
    it 'installs to home directory' do
      path = Gem.default_dir
      assert_equal path, Etc.getpwuid.dir + "/.ruby-standalone/gems/ruby/#{RUBY_API_VERSION}"
    end

    it 'installs programs to home directory' do
      assert_equal Gem.default_bindir, Etc.getpwuid.dir + "/.ruby-standalone/gems/ruby/#{RUBY_API_VERSION}/bin"
    end
  end

  it 'makes default gems available' do
    assert_equal Gem.default_specifications_dir, "/usr/lib/ruby/gems/#{RUBY_API_VERSION}/specifications/default"
  end

  it 'sets a default path' do
    path = Gem.default_path
    path.include?(Gem.user_dir) &&
      path.include?("/usr/lib/ruby/gems/#{RUBY_API_VERSION}") &&
      path.include?("/var/lib/gems/#{RUBY_API_VERSION}")
  end

  it 'sets path to ruby binary' do
    assert_no_match Gem.ruby, %r{^/usr/bin}
  end

end

exit(RubyStandaloneSpec.run)
