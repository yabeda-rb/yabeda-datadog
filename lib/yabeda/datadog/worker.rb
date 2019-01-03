# frozen_string_literal: true

require "yabeda/datadog/worker/send"
require "yabeda/datadog/worker/register"

module Yabeda
  module Datadog
    # = Perform synchronous actions
    class Worker
      BATCH_SIZE = 10
      QUEUE_SIZE = 1000
      NUM_THREADS = 2
      SLEEP_INTERVAL = 3

      def self.start(queue_size: QUEUE_SIZE)
        Logger.instance.info "start worker"
        instance = new(SizedQueue.new(queue_size))
        instance.spawn_threads(NUM_THREADS)
        instance
      end

      def initialize(queue)
        @queue = queue
        @threads = []
        @logger = Logger.instance
      end

      def enqueue(action, payload)
        logger.info "enqueue action"
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
        dispatch_actions until no_acitons?
        threads.each(&:exit)
        threads.clear
        true
      end

      private

      attr_reader :queue, :threads, :logger

      def dispatch_actions
        grouped_actions = Hash.new { |hash, key| hash[key] = [] }
        batch_size = 0

        while batch_size < self.class::BATCH_SIZE && actions_left?
          begin
            action_key, action_payload = dequeue_action
            grouped_actions[action_key].push(action_payload)
            batch_size += 1
          rescue ThreadError
            next
          end
        end

        grouped_actions.each_pair do |group_key, group_payload|
          self.class.const_get(group_key, false).call(group_payload)
        end
      end

      def actions_left?
        !queue.empty?
      end

      def no_acitons?
        queue.empty?
      end

      def dequeue_action
        queue.pop(true)
      end
    end
  end
end
