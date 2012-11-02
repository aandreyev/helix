require 'rest_client'
require 'json'
require 'yaml'

module Helix
  class Base

    unless defined?(self::CREDENTIALS)
      FILENAME    = '/home/kbaird/sandbox/Twistage/Helix.git/helix.yml'
      CREDENTIALS = YAML.load(File.open(FILENAME))
    end

    attr_accessor :attributes

    def self.find(guid, opts={})
      item = self.new(attributes: { guid_name => guid })
      item.load
    end

    def self.find_all(opts)
      # TODO: DRY up w/load
      url         = "#{CREDENTIALS['site']}/#{plural_media_type}.json"
      params      = opts.merge(signature: signature)
      response    = RestClient.get(url, params: params)
      data_sets   = JSON.parse(response)
      data_sets[plural_media_type].map { |attrs| self.new(attributes: attrs) }
    end

    # TODO: messy near-duplication. Clean up.
    def self.signature
      self.new({}).signature
    end

    def guid
      @attributes[guid_name]
    end

    def initialize(opts)
      @attributes = opts[:attributes]
    end

    def load(opts={})
      # TODO: DRY up w/find_all
      url         = "#{CREDENTIALS['site']}/#{plural_media_type}/#{guid}.json"
      params      = opts.merge(signature: signature)
      response    = RestClient.get(url, params: params)
      @attributes = JSON.parse(response)
      self
    end
    alias_method :reload, :load

    def method_missing(method_sym)
      @attributes[method_sym.to_s]
    end

    def signature
      # TODO: Memoize (if it's valid)
      url = "#{CREDENTIALS['site']}/api/update_key?licenseKey=#{CREDENTIALS['license_key']}&duration=1200"
      # FIXME: Replace Net::HTTP with our own connection abstraction
      @signature = Net::HTTP.get_response(URI.parse(url)).body
    end

    def update(opts={})
      url    = "#{CREDENTIALS['site']}/#{plural_media_type}/#{guid}.xml"
      params = {signature: signature}.merge(media_type_sym => opts)
      RestClient.put(url, params)
      self
    end

    private

    def guid_name;         "#{media_type_sym}_id"; end
    def plural_media_type; "#{media_type_sym}s";   end

  end
end