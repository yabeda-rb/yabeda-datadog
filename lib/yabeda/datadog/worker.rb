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
<<<<<<< HEAD
        Logger.instance.info "start worker"
=======
>>>>>>> aa2b4c9fe9bb173ecaf46ef54c8f1491205f13f9
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
<<<<<<< HEAD
        logger.info "enqueue action"
=======
>>>>>>> aa2b4c9fe9bb173ecaf46ef54c8f1491205f13f9
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
<<<<<<< HEAD
        logger.info "going to dispatch actions in thread #{Thread.current.object_id}, queue size #{queue.size}"
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
          logger.info "sending next set of metrics in thread #{Thread.current.object_id}"
          dogstatsd = ::Datadog::Statsd.new(
            ENV.fetch("DATADOG_AGENT_HOST", DEFAULT_AGENT_HOST),
            ENV.fetch("DATADOG_AGENT_PORT", DEFAULT_AGENT_PORT),
          )

          dogstatsd.batch do |stats|
            send.each do |payload|
              metric = payload.fetch(:metric)
              value = payload.fetch(:value)
              tags = payload.fetch(:tags)

              logger.log_request metric do
                stats.send(metric.type, metric.name, value, tags: tags)
              end
            end
          end
=======
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
>>>>>>> aa2b4c9fe9bb173ecaf46ef54c8f1491205f13f9
        end
      end

<<<<<<< HEAD
        if register.any?
          logger.info "updating next set of metrics in thread #{Thread.current.object_id}"
          dogapi = ::Dogapi::Client.new('b62b7b523bf06ec87743f8e29ed17569', ENV["DATADOG_APP_KEY"])

          register.each do |payload|
            metric = payload.fetch(:metric)
            logger.log_request metric do
              metric.update(dogapi)
            end
          end
        end
=======
      def actions_left?
        !queue.empty?
>>>>>>> aa2b4c9fe9bb173ecaf46ef54c8f1491205f13f9
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
