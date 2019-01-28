# frozen_string_literal: true

module Yabeda
  module Datadog
    # = The logic of working with Datadog units
    class Unit
      # Datadog whitelist of units
      # source: https://docs.datadoghq.com/developers/metrics/#units
      AVAILABLE = [
        "bit", "byte", "kibibyte", "mebibyte", "gibibyte", "tebibyte",
        "pebibyte", "exbibyte", "nanosecond", "microsecond", "millisecond",
        "second", "minute", "hour", "day", "week", "percent_nano", "percent",
        "apdex", "fraction", "connection", "request", "packet", "segment",
        "response", "message", "payload", "timeout", "datagram", "route",
        "session", "process", "thread", "host", "node", "fault", "service",
        "instance", "cpu", "file", "inode", "sector", "block", "buffer",
        "error", "read", "write", "occurrence", "event", "time", "unit",
        "operation", "item", "task", "worker", "resource", "garbage collection",
        "email", "sample", "stage", "monitor", "location", "check", "attempt",
        "device", "update", "method", "job", "container", "execution",
        "throttle", "invocation", "user", "success", "build", "prediction",
        "table", "index", "lock", "transaction", "query", "row", "key",
        "command", "offset", "record", "object", "cursor", "assertion", "scan",
        "document", "shard", "flush", "merge", "refresh", "fetch", "column",
        "commit", "wait", "ticket", "question", "hit", "miss", "eviction",
        "get", "set", "dollar", "cent", "page", "split", "hertz", "kilohertz",
        "megahertz", "gigahertz", "entry", "degree celsius", "degree fahrenheit",
        "nanocore", "microcore", "millicore", "core", "kilocore", "megacore",
        "gigacore", "teracore", "petacore", "exacore",
      ].map { |unit| [unit, unit] }.to_h.freeze

      IRREGULAR_PLURALS = {
        "queries" => "query",
        "entries" => "entry",
        "indices" => "index",
      }.freeze

      # Find an available unit of metric
      def self.find(unit)
        unit_key = unit.to_s.downcase
        AVAILABLE[unit_key] ||
          AVAILABLE[unit_key.gsub(/s\z/, "")] ||
          AVAILABLE[unit_key.gsub(/es\z/, "")] ||
          IRREGULAR_PLURALS[unit_key]
      end
    end
  end
end
