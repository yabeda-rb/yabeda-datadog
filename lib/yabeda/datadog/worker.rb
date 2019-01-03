# frozen_string_literal: true

require "yabeda/datadog/worker/send"
require "yabeda/datadog/worker/register"

module Yabeda
  module Datadog
    # = Perform actions async
    class Worker
      def self.start(queue_size: Yabeda::Datadog.config.queue_size)
        instance = new(SizedQueue.new(queue_size))
        instance.spawn_threads(Yabeda::Datadog.config.num_threads)
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
              sleep(rand(Yabeda::Datadog.config.sleep_interval))
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
        grouped_actions = Hash.new { |hash, key| hash[key] = [] }
        batch_size = 0

        while batch_size < Yabeda::Datadog.config.batch_size && actions_left?
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
