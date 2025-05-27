require 'semantic_logger/formatters/base'
require 'socket'
require 'json'
require_relative '../lib/ecs_json_formatter'

class ECSJsonFormatter < SemanticLogger::Formatters::Base
  def call(log, logger)
    {
      '@timestamp' => log.time.utc.iso8601(3),
      'log.level' => log.level.to_s,
      'message' => log.message,
      'process.pid' => Process.pid,
      'host.hostname' => Socket.gethostname,
      'service.name' => logger.application,
      'event.dataset' => 'application',
      'log.logger' => log.name,
      'tags' => log.tags,
      'duration' => log.duration,
      'exception' => log.exception&.message,
      'backtrace' => log.backtrace&.join("\n")
    }.compact.to_json
  end
end
