# frozen_string_literal: true

module Yabeda
  module Datadog
    # = Perform synchronous actions
    class Worker
      QUEUE_SIZE = 100 # TODO: think twice about it
      NUM_THREADS = 2
      SLEEP_INTERVAL = 5 # TODO: think twice about it
      ACTIONS = {
        send: proc {},
        register: proc {},
      }.freeze

      def self.start(queue_size: QUEUE_SIZE)
        instance = new(SizedQueue.new(queue_size))
        instance.spawn_threads(NUM_THREADS)
        instance
      end

      def initialize(queue)
        @queue = queue
        @threads = []
      end

      def enqueue(action, payload)
        queue.push([action, payload])
      end

      def spawn_threads(num_threads)
        num_threads.times do
          threads << Thread.new do
            loop do
              dispatch_actions
              sleep(SLEEP_INTERVAL)
            end
          end
        end
        true
      end

      def spawned_threads_count
        threads.size
      end

      def stop
        dispatch_actions until no_acitons?
        threads.each(&:exit)
        threads.clear
        true
      end

      private

      attr_reader :queue, :threads

      def dispatch_actions
        queue.pop
      end

      def no_acitons?
        queue.empty?
      end
    end
  end
end
