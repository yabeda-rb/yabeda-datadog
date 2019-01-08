# frozen_string_literal: true

require "yabeda/datadog/worker/send"
require "yabeda/datadog/worker/register"

module Yabeda
  module Datadog
    # = Perform actions async
    class Worker
      def self.start(config)
        queue = SizedQueue.new(config.queue_size)
        instance = new(queue)
        instance.spawn_threads(config.num_threads)
        instance
      end

      def initialize(queue)
        @queue = queue
        @threads = []
      end

      def enqueue(action, payload)
        Logging.instance.info "enqueue action"
        queue.push([action, payload])
      end

      def spawn_threads(num_threads)
        num_threads.times do
          threads << Thread.new do
            grouped_actions = Hash.new { |hash, key| hash[key] = [] }

            while running? || actions_left?
              batch_size = 0
              # wait for actions, blocks the current thread
              action_key, action_payload = wait_for_action
              if action_key
                grouped_actions[action_key].push(action_payload)
                batch_size += 1
              end

              # group a batch of actions
              while batch_size < Yabeda::Datadog.config.batch_size
                begin
                  action_key, action_payload = dequeue_action
                  grouped_actions[action_key].push(action_payload)
                  batch_size += 1
                rescue ThreadError
                  break # exit batch loop if we drain the queue
                end
              end

              # invoke actions in batches
              grouped_actions.each_pair do |group_key, group_payload|
                self.class.const_get(group_key, false).call(group_payload)
              end

              grouped_actions.clear
            end
          end
        end

        true
      end

      def spawned_threads_count
        threads.size
      end

      def stop
        queue.close
        threads.each(&:exit)
        threads.clear
        true
      end

      private

      attr_reader :queue, :threads, :logger

      def actions_left?
        !queue.empty?
      end

      def no_acitons?
        queue.empty?
      end

      def dequeue_action
        queue.pop(true)
      end

      def wait_for_action
        queue.pop(false)
      end

      def running?
        !queue.closed?
      end
    end
  end
end
