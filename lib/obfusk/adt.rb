# --                                                            ; {{{1
#
# File        : obfusk/adt.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-15
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

module Obfusk

  # Algebraic Data Type
  module ADT
    include Comparable

    def self.included(base)
      base.extend ClassMethods
    end

    # use a contructor!
    # @raise NoMethodError
    def initialize
      raise NoMethodError, 'use a contructor!'  # TODO
    end

    module ClassMethods
      # create a constructor
      # @param [Symbol]   name  the name of the constructor
      # @param [<Symbol>] keys  the keys of the constructor
      def constructor(name, *keys, &b)
        self_ = self
        keys_ = keys.map(&:to_sym)
        name_ = name.to_sym
        ctor  = Class.new self
        ctor.class_eval do
          attr_accessor :cls, :ctor, :ctor_name, :ctor_keys
          keys_.each { |k| define_method(k) { @data[k] } }
          define_method(:initialize) do |guard, cls, ctor, *values, &f|
            raise ArgumentError, 'for internal use only!' \
              unless guard == :for_internal_use_only
            if !b && (k = keys_.length) != (v = values.length)
              raise ArgumentError, "wrong number of arguments (#{v} for #{k})"
            end
            data  = Hash[keys_.zip values]
            @cls  = cls; @ctor = ctor; @ctor_name = name_; @ctor_keys = keys_
            @data = b ? b[self, data, values, f] : data
          end
        end
        class_eval do
          if !@constructors
            @constructors = superclass.ancestors.include?(::Obfusk::ADT) ?
                              superclass.constructors.dup : {}
          end
          const_set name_, ctor
          f = -> v, b { ctor.new :for_internal_use_only, self_, ctor, *v, &b }
          if !b && keys.empty?
            singleton = f[[],nil]
            define_singleton_method(name_) { singleton }
            define_method(name_)           { singleton }
          else
            define_singleton_method(name_) { |*values,&b| f[values,b] }
            define_method(name_)           { |*values,&b| f[values,b] }
          end
          @constructors[name_] = { ctor: ctor, method: method(name_) }
        end
      end
      private :constructor

      # the constructors
      def constructors
        @constructors
      end

      # import the constructors into another namespace
      def import_constructors(scope)
        constructors.each_pair do |k,v|
          m = method k
          scope.define_singleton_method(k) { |*a,&b| m[*a,&b] }
          scope.const_set k, v[:ctor]
        end
      end

      # pattern matching
      def match(x, opts)
        unless x.cls == self
          raise ArgumentError, "types do not match (#{x.cls} for #{self})"
        end
        x.match opts
      end
    end

    # the data
    def _data
      @data
    end

    # equal?
    def ==(rhs)
      cls == rhs.cls && ctor == rhs.ctor && _data == rhs._data
    end

    # equal and of the same type?
    def eql?(rhs)
      self == rhs
    end

    # ordering
    def <=>(rhs)
      cls == rhs.cls && ctor == rhs.ctor ? _data <=> rhs._data : nil
    end

    # pattern matching
    def match(opts)
      unless (ck = cls.constructors.keys.sort) == (ok = opts.keys.sort)
        raise ArgumentError,
          "constructors do not match (#{ok} for #{ck})"
      end
      opts[ctor_name][self]
    end

    # to string
    def to_s
      ctor_name = ctor.name.gsub(/^.*::/,'')
      "#<#{cls.name}.#{ctor_name}: #{@data}>"
    end

    # to string
    def inspect
      to_s
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
