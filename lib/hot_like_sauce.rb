require 'openssl'
require 'active_record'

module HotLikeSauce

  def self.secret_key
    @secret_key ||= "please_init_this_somewhere_before_using"
  end

  def self.secret_key=(val)
    @secret_key = val
  end

  def self.crypto_method
    @crypto_method ||= "aes-256-cbc"
  end

  def self.crypto_method=(val)
    @crypto_method = val
  end

  module ARMethods

    def inherited(child_class)
      child_class.send :extend,  HotLikeSauce::ClassMethods
      child_class.send :include, HotLikeSauce::InstanceMethods
    end

  end

  module ClassMethods

    def obscured_fields
      @obscured_fields ||= []
    end

    def obscured_fields=(val)
      @obscured_fields = val
    end

    def unobscured_read_fields
      @unobscured_read_fields ||= []
    end

    def unobscured_read_fields=(val)
      @unobscured_read_fields = val
    end

    def attr_obscurable(*args)
      fields = args.map {|arg| arg if arg.is_a?(Symbol)}.compact

      fields.each do |field|

        type = self.columns_hash[field.to_s].type
        raise "#{field} must be a string or text field" unless type == :string || type == :text
        self.obscured_fields = (self.obscured_fields << field).uniq
        self.unobscured_read_fields = (self.unobscured_read_fields << field).uniq

        define_method field do
          super()
          value = read_attribute(field)
          self.class.unobscured_read_fields.include?(field) ? _unobscure(value) : value
        end

        define_method "#{field}=" do |value|
          super(value)
          write_attribute(field, _obscure(value))
        end

      end

    end

    def obscure_read_on_fields!(*fields_array)
      if fields_array.empty?
        self.unobscured_read_fields = []
      else
        self.unobscured_read_fields -= fields_array
      end
    end

    def unobscure_read_on_fields!(*fields_array)
      if fields_array.empty?
        self.unobscured_read_fields = self.obscured_fields
      else
        self.unobscured_read_fields += self.obscured_fields & fields_array
      end
    end

  end

  module InstanceMethods

  private

    def _obscure(value)
      _crypt :encrypt, HotLikeSauce::secret_key, value
    end

    def _unobscure(value)
      _crypt :decrypt, HotLikeSauce::secret_key, value
    end

    def _crypt(method, key, value)
      cipher = OpenSSL::Cipher::Cipher.new(HotLikeSauce::crypto_method)
      cipher.send(method)
      cipher.pkcs5_keyivgen(key)
      result = cipher.update(value)
      result << cipher.final
      result.force_encoding('UTF-8')
    end

  end

end


ActiveRecord::Base.send :extend,  HotLikeSauce::ARMethods
