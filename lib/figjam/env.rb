module Figjam
  module ENV
    extend self

    def respond_to?(method, *)
      key, punctuation = extract_key_from_method(method)

      case punctuation
      when "!" then has_key?(key) || super # rubocop:disable Style/PreferredHashMethods
      when "?", nil then true
      else super
      end
    end

    # rubocop:disable Style/MissingRespondToMissing
    private def method_missing(method, *)
      key, punctuation = extract_key_from_method(method)

      case punctuation
      when "!" then send(key) || missing_key!(key)
      when "?" then !!send(key)
      when nil then get_value(key)
      else super
      end
    end
    # rubocop:enable Style/MissingRespondToMissing

    private def extract_key_from_method(method)
      method.to_s.downcase.match(/^(.+?)([!?=])?$/).captures
    end

    # rubocop:disable Naming/PredicateName
    private def has_key?(key)
      ::ENV.any? { |k, _| k.downcase == key }
    end
    # rubocop:enable Naming/PredicateName

    private def missing_key!(key)
      raise MissingKey, key
    end

    private def get_value(key)
      _, value = ::ENV.detect { |k, _| k.downcase == key }
      value
    end
  end
end
