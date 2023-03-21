# frozen_string_literal: true

require_relative "liblocation/version"
require_relative "liblocation/config"
require_relative "liblocation/server"

module LibLocation
  def geo2address(geo_point, config_file = nil, host = nil, version = nil, verify = true, debug = false)
    config = if !config_file.nil?
               LibLocation::LocationConfig.from_file(config_file) if File.exist?(config_file)
             else
               LibLocation::LocationConfig.instance(host, version, verify, debug)
             end

    LibLocation::LocationServer.geo2address(config, geo_point)
  end

  def address2geo(address, config_file = nil, host = nil, version = nil, verify = true, debug = false)
    config = if !config_file.nil?
               LibLocation::LocationConfig.from_file(config_file) if File.exist?(config_file)
             else
               LibLocation::LocationConfig.instance(host, version, verify, debug)
             end

    LibLocation::LocationServer.address2geo(config, address)
  end

  module_function :geo2address, :address2geo
end
