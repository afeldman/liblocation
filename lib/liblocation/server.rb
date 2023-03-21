# frozen_string_literal: true

require "json"
require "httparty"
require "shale"

require_relative "config"

# send data to the libphone api server and get the responce
module LibLocation
  class LocationServer
    class Address < Shale::Mapper
      attribute :FormattedAddress, Shale::Type::String, default: -> { "" }
      attribute :Street, Shale::Type::String, default: -> { "" }
      attribute :HouseNumber, Shale::Type::String, default: -> { "" }
      attribute :Suburb, Shale::Type::String, default: -> { "" }
      attribute :Postcode, Shale::Type::String, default: -> { "" }
      attribute :State, Shale::Type::String, default: -> { "" }
      attribute :StateCode, Shale::Type::String, default: -> { "" }
      attribute :StateDistrict, Shale::Type::String, default: -> { "" }
      attribute :County, Shale::Type::String, default: -> { "" }
      attribute :Country, Shale::Type::String, default: -> { "" }
      attribute :CountryCode, Shale::Type::String, default: -> { "" }
      attribute :City, Shale::Type::String, default: -> { "" }
    end

    class Geo < Shale::Mapper
      attribute :type, Shale::Type::String, default: -> { "Point" }
      attribute :coordinates, Shale::Type::Float, collection: true
    end

    class << self
      def geo2address(config, geo_point)
        res = nil
        p geo_point
        begin
          options = {
            headers: {
              "Content-Type" => "application/json",
              "Accept" => "application/json"
            },
            body: geo_point,
            verify: config.config.verify
          }

          options[:debug_output] = $stdout if config.config.debug
          res = HTTParty.post(
            "#{config.config.host}/#{config.config.version}/geo2address",
            options
          )
        rescue StandartError => e
          puts e.message
        end

        return if res.body.nil? || res.body.empty? && res.code != 200

        Geo.from_hash(JSON.parse(res.body.force_encoding("utf-8")))
      end

      def address2geo(config, address)
        res = nil
        begin
          options = {
            headers: {
              "Content-Type" => "application/json",
              "Accept" => "application/json"
            },
            body: address,
            verify: config.config.verify
          }

          options[:debug_output] = $stdout if config.config.debug
          res = HTTParty.post(
            "#{config.config.host}/#{config.config.version}/address2geo",
            options
          )
        rescue StandartError => e
          puts e.message
        end

        return if res.body.nil? || res.body.empty? && res.code != 200

        Geo.from_hash(JSON.parse(res.body.force_encoding("utf-8")))
      end
    end
  end
end
