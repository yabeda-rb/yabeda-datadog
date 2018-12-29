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
        puts "going to dispatch actions in thread #{Thread.current.object_id}, queue size #{queue.size}"
        send = []
        register = []

        until no_acitons?
          action_key, action_payload = dequeue_action
          case action_key
          when :send then send.push(action_payload)
          when :register then register.push(action_payload)
          end
        end

        if send.any?
          puts "sending next set of metrics in thread #{Thread.current.object_id}"
          dogstatsd = ::Datadog::Statsd.new(
            ENV.fetch("DATADOG_AGENT_HOST", DEFAULT_AGENT_HOST),
            ENV.fetch("DATADOG_AGENT_PORT", DEFAULT_AGENT_PORT),
          )

          dogstatsd.batch do |stats|
            send.each do |payload|
              puts "sending metric"

              metric = payload.fetch(:metric)
              value = payload.fetch(:value)
              tags = payload.fetch(:tags)

              puts "value: #{value}"

              stats.send(metric.type, metric.name, value, tags: tags)
            end
          end
        end

        if register.any?
          puts "updating next set of metrics in thread #{Thread.current.object_id}"
          dogapi = ::Dogapi::Client.new(ENV["DATADOG_API_KEY"], ENV["DATADOG_APP_KEY"])

          register.each do |payload|
            metric = payload.fetch(:metric)
            metric.update(dogapi)
          end
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
