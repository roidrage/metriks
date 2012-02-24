require 'test_helper'

require 'logger'
require 'metriks/reporter/logger'

class LoggerReporterTest < Test::Unit::TestCase
  def setup
    @stringio = StringIO.new
    @logger   = ::Logger.new(@stringio)
    @registry = Metriks::Registry.new

    @reporter = Metriks::Reporter::Logger.new(:registry => @registry, :logger => @logger)
  end

  def teardown
    @reporter.stop
    @registry.stop
  end

  def test_write
    @registry.meter('meter.testing').mark
    @registry.counter('counter.testing').increment
    @registry.timer('timer.testing').update(1.5)
    @registry.utilization_timer('utilization_timer.testing').update(1.5)

    @reporter.write

    assert_match /time=\d/, @stringio.string
  end

  def test_should_include_source_if_present
    @registry.meter('meter.testing', 'test-case').mark
    @reporter.write
    assert_match /source=test-case/, @stringio.string
  end

  def test_should_not_include_source_if_nil
    @registry.meter('meter.testing').mark
    @reporter.write
    assert_not_match /source=/, @stringio.string
  end
end
