# frozen_string_literal: true

require_relative "liblocation/version"

module LibLocation
  def phone_informations(phonenumber, country = "DE", config_file = nil, host = nil, verify = nil)
    c = ISO3166::Country.find_country_by_alpha2(country) unless country.nil?

    phonenumber = if !c.nil? && phonenumber.start_with?("0")
                    "+#{c.country_code}#{phonenumber[1..]}"
                  else
                    phonenumber
                  end

    LibPhone::Phone.phone(phonenumber, config_file, host, verify)
  end
end
