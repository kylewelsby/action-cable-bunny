# frozen_string_literal: true

require "spec_helper"
require "rails"
require "action_cable"
require_relative "../../../lib/action_cable/subscription_adapter/bunny"
require "concurrent"
require "active_support/core_ext/hash/indifferent_access"

RSpec.describe ActionCable::SubscriptionAdapter::Bunny do
  WAIT_WHEN_EXPECTING_EVENT = 1
  WAIT_WHEN_NOT_EXPECTING_EVENT = 1

  before :each do
    # logger = double(:logger)
    # allow_any_instance_of(Rails).to receive(:logger).and_return(logger)
    # allow(logger).to receive(:info)
    # allow(Rails.logger).to receive(:info)
    stub_const("AMQP_CONFIG", nil)

    cable_config = {adapter: "bunny"}
    server = ActionCable::Server::Base.new
    server.config.cable = cable_config.with_indifferent_access
    server.config.logger = Logger.new(STDOUT).tap { |l| l.level = Logger::UNKNOWN }

    adapter_klass = server.config.pubsub_adapter

    @rx_adapter = adapter_klass.new(server)
    @tx_adapter = adapter_klass.new(server)
    @tx_adapter.shutdown
    @tx_adapter = @rx_adapter
  end

  after :each do
    [@rx_adapter, @tx_adapter].uniq.compact.each(&:shutdown)
  end

  def subscribe_as_queue(channel, adapter = @rx_adapter)
    queue = Queue.new
    callback =
      ->(data) do
        queue << data # unless queue.closed?
      end
    subscribed = Concurrent::Event.new
    adapter.subscribe(channel, callback, proc { subscribed.set })
    subscribed.wait(WAIT_WHEN_EXPECTING_EVENT)

    expect(subscribed).to respond_to(:set?)
    yield queue

    sleep WAIT_WHEN_NOT_EXPECTING_EVENT

    expect(queue).to be_empty
    queue.close

    adapter.unsubscribe(channel, ->(data) {})
  end

  it "subscribe and unsubscribe" do
    subscribe_as_queue("MyChannel") do |queue|
    end
  end

  it "basic broadcast" do
    subscribe_as_queue("MyChannel2") do |queue|
      @tx_adapter.broadcast("MyChannel2", "hello world")

      expect(queue.pop).to eq '"hello world"'
    end
  end

  it "broadcast after unsubscribe" do
    keep_queue = nil
    subscribe_as_queue("MyChannel3") do |queue|
      keep_queue = queue
      @tx_adapter.broadcast("MyChannel3", "hello world")

      expect(queue.pop).to eq '"hello world"'
    end

    @tx_adapter.broadcast("MyChannel3", "hello world again")

    sleep WAIT_WHEN_NOT_EXPECTING_EVENT
    # byebug
    expect(keep_queue).to be_empty
  end

  it "multiple broadcast" do
    subscribe_as_queue("MyChannel4") do |queue|
      @tx_adapter.broadcast("MyChannel4", "apples")
      @tx_adapter.broadcast("MyChannel4", "bananas")

      received = []

      2.times { received << queue.pop }

      expect(received).to include(%("apples"))
      expect(received).to include(%("bananas"))
    end
  end

  it "identical subscriptions" do
    subscribe_as_queue("MyChannel5") do |queue|
      subscribe_as_queue("MyChannel5") do |queue_2|
        @tx_adapter.broadcast("MyChannel5", "hello world")

        expect(queue_2.pop).to eq '"hello world"'
      end

      expect(queue.pop).to eq '"hello world"'
    end
  end

  it "simultaneous subscriptions" do
    subscribe_as_queue("MyChannel6") do |queue|
      subscribe_as_queue("MyChannel7") do |queue_2|
        @tx_adapter.broadcast("MyChannel6", "apples")
        @tx_adapter.broadcast("MyChannel7", "bananas")
        expect(queue.pop).to eql(%("apples"))
        expect(queue_2.pop).to eql(%("bananas"))
      end
    end
    sleep WAIT_WHEN_NOT_EXPECTING_EVENT
  end

  it "channel filtered broadcast" do
    subscribe_as_queue("MyChannel8") do |queue|
      @tx_adapter.broadcast("MyChannel8", "one")
      @tx_adapter.broadcast("MyChannel7", "two")
      expect(queue.pop).to eql(%("one"))
    end
  end
end
