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

    def initialize(config_file)
      @config = Config.new
      return unless config_file.nil? || File.exist?(config_file)

      content = File.read(config_file)

      case File.extname(config_file).downcase
      when ".tml", ".toml"
        @config = Config.from_toml(content)
      when ".yml", ".yaml"
        @config = Config.from_yaml(content)
      when ".json"
        @config = Config.from_json(content)
      when ".xml"
        @config = Config.from_xml(content)
      else
        @config
      end
    end

    def self.instance(config_file)
      return @instance if @instance

      @instance_mutex.synchronize do
        @instance ||= new(config_file)
      end

      @instance
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
