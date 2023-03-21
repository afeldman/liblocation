# frozen_string_literal: true

require "shale"
require "tomlib"

module LibLocation
  class LocationConfig
    class Config < Shale::Mapper
      attribute :host, Shale::Type::String, default: -> { "localhost" }
      attribute :verify, Shale::Type::Boolean, default: -> { true }
      attribute :version, Shale::Type::String, default: -> { "v1" }
      attribute :debug, Shale::Type::Boolean, default: -> { false }
    end

    attr_reader :config

    @instance_mutex = Mutex.new

    private_class_method :new

    def initialize(host = nil, _version = nil, _verify = nil, _debug = nil)
      @config = Config.new

      @config.host = host unless host.nil?
      @config.version = version unless version.nil?
      @config.verify = verify unless verify.nil?
      @config.debug = debug unless debug.nil?
    end

    class << self
      def instance(host = nil, version = nil, verify = nil, debug = nil)
        return @instance if @instance

        @instance_mutex.synchronize do
          @instance ||= new(host: host, version: version, verify: verify, debug: debug)
        end

        @instance
      end

      def from_file(config_file = nil)
        config = LocationConfig.instance
        if !config_file.nil? && File.exist?(config_file)

          content = File.read(config_file)
          info = nil

          case File.extname(config_file).downcase
          when ".tml", ".toml"
            info = Config.from_toml(content)
          when ".yml", ".yaml"
            info = Config.from_yaml(content)
          when ".json"
            info = Config.from_json(content)
          when ".xml"
            info = Config.from_xml(content)
          else
            info
          end
          config.config = info
        end

        config
      end
    end

    def to_toml
      Shale.toml_adapter = Tomlib
      @config.to_toml
    end

    def to_cjson
      @config.to_json
    end

    def to_yaml
      @config.to_yaml
    end
  end
end
