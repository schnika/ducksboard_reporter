require "spec_helper"


class FooReporter < DucksboardReporter::Reporter
  attr_accessor :log_file, :condition

  def initialize(*args)
    @condition = Celluloid::Condition.new
    super
  end

  def collect
    sleep 0.001
    @condition.signal("called")
  end

  def collect_called
    @condition.wait
    true
  end
end

describe DucksboardReporter::Reporter do

  let(:reporter) { FooReporter.new("foo") }

  describe "#collect" do
    it "will be called on start" do
      reporter.start
      expect(reporter.collect_called).to be(true)
    end
  end

  describe "#timestamp" do
    it "returns current time" do
      expect(reporter.timestamp).to be_within(1).of(Time.now.to_i)
    end

    it "returns set timestamp" do
      time = Time.now.to_i + 10
      reporter.timestamp = time
      expect(reporter.timestamp).to eq(time)
    end
  end
end

