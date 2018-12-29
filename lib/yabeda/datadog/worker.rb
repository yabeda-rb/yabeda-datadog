# frozen_string_literal: true

module Yabeda
  module Datadog
    # = Perform synchronous actions
    class Worker
      QUEUE_SIZE = 100 # TODO: think twice about it
      NUM_THREADS = 2 # TODO: think twice about it
      SLEEP_INTERVAL = 5 # TODO: think twice about it
      DEFAULT_AGENT_HOST = "localhost"
      DEFAULT_AGENT_PORT = 8125
      ACTIONS = {
        send: proc do |payload|
          puts "sending metric"

          metric = payload.fetch(:metric)
          value = payload.fetch(:value)
          tags = payload.fetch(:tags)

          puts "value: #{value}"

          dogstatsd = ::Datadog::Statsd.new(
            ENV.fetch("DATADOG_AGENT_HOST", DEFAULT_AGENT_HOST),
            ENV.fetch("DATADOG_AGENT_PORT", DEFAULT_AGENT_PORT),
          )

          dogstatsd.send(metric.type, metric.name, value, tags: tags)
        end,

        register: proc do |payload|
          puts "updating metadata"

          dogapi = ::Dogapi::Client.new(ENV["DATADOG_API_KEY"], ENV["DATADOG_APP_KEY"])
          metric = payload.fetch(:metric)
          metric.update(dogapi)
        end,
      }.freeze

      def self.start(queue_size: QUEUE_SIZE)
        puts "start worker"
        instance = new(SizedQueue.new(queue_size))
        instance.spawn_threads(NUM_THREADS)
        instance
      end

      def initialize(queue)
        @queue = queue
        @threads = []
      end

      def enqueue(action, payload)
        puts "enqueue action"
        queue.push([action, payload])
      end

      def spawn_threads(num_threads)
        num_threads.times do
          threads << Thread.new do
            loop do
              dispatch_actions
              sleep(rand(SLEEP_INTERVAL))
            end
          end
        end
        true
      end

      def spawned_threads_count
        threads.size
      end

      def stop
        dispatch_actions
        threads.each(&:exit)
        threads.clear
        true
      end

      private

      attr_reader :queue, :threads

      def dispatch_actions
        puts "going to dispatch actions in thread #{Thread.current.object_id}"
        until no_acitons?
          puts "dispatch next action in thread #{Thread.current.object_id}"
          action_key, payload = dequeue_action
          action = self.class::ACTIONS[action_key]
          action.call(payload)
        end
      end

      def no_acitons?
        queue.empty?
      end

      def dequeue_action
        queue.pop
      end
    end
  end
end
