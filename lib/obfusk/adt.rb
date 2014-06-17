# --                                                            ; {{{1
#
# File        : obfusk/adt.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-17
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'thread'

module Obfusk

  ADT_Meta__ = { inheriting: [false], mutex: Mutex.new }

  # Algebraic Data Type
  module ADT
    module Constructor; end

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
      # record constructor; call with name of constructor and hash of
      # keys to values
      def new(*a, &b)
        ancestors.include?(::Obfusk::ADT::Constructor) ? super : _new(*a, &b)
      end

      def _new(ctor, data = {}, &b)
        c = constructors[ctor]
        c[:method].call *data.values_at(*c[:keys]), &b
      end

      # duplicate constructors for subclasses
      def inherited(subclass)
        return if ::Obfusk::ADT_Meta__[:inheriting].last
        ctors = constructors
        subclass.class_eval do
          ctors.each_pair do |k,v|
            constructor v[:name], *v[:keys], &v[:block]
          end
        end
      end

      # create a constructor
      # @param [Symbol]   name  the name of the constructor
      # @param [<Symbol>] keys  the keys of the constructor
      def constructor(name, *keys, &b)
        keys_ = keys.map(&:to_sym)
        name_ = name.to_sym
        ctor  = ::Obfusk::ADT_Meta__[:mutex].synchronize do
          begin
            ::Obfusk::ADT_Meta__[:inheriting] << true
            Class.new self
          ensure
            ::Obfusk::ADT_Meta__[:inheriting].pop
          end
        end
        ctor.class_eval do
          include ::Obfusk::ADT::Constructor
          attr_accessor :ctor, :ctor_name, :ctor_keys
          keys_.each { |k| define_method(k) { data[k] } }
          define_method(:initialize) do |guard, ctor, *values, &f|
            raise ArgumentError, 'for internal use only!' \
              unless guard == :for_internal_use_only
            if !b && (k = keys_.length) != (v = values.length)
              raise ArgumentError, "wrong number of arguments (#{v} for #{k})"
            end
            data  = Hash[keys_.zip values].freeze
            @ctor = ctor ; @ctor_name = name_ ; @ctor_keys = keys_
            @data = b ? b[self, data, values, f].freeze : data
          end
        end
        class_eval do
          const_set name_, ctor
          f = -> v, b { ctor.new :for_internal_use_only, ctor, *v, &b }
          if !b && keys.empty?
            singleton = f[[],nil]
            define_singleton_method(name_) { singleton }
            define_method(name_)           { singleton }
          else
            define_singleton_method(name_) { |*values,&b| f[values,b] }
            define_method(name_)           { |*values,&b| f[values,b] }
          end
          constructors[name_] = {
            ctor: ctor, method: method(name_), name: name_,
            keys: keys_, block: b
          }
        end
        name_
      end
      private :constructor

      # the constructors
      def constructors
        @constructors ||= {}
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
        raise ArgumentError, 'not an ADT' unless x.is_a?(::Obfusk::ADT)
        raise ArgumentError,
          "types do not match (#{x.class.superclass} for #{self})" \
            unless x.class.superclass == self
        x.match opts
      end
    end

    # clone
    def clone(merge_data = {})
      merge_data.empty? ? self :
        self.class.superclass.new(ctor_name, data.merge(merge_data))
    end

    # the data
    def data
      @data
    end

    # equal?
    def ==(rhs)
      rhs.is_a?(::Obfusk::ADT) &&
        self.class.superclass == rhs.class.superclass &&
        ctor == rhs.ctor && _eq_data(rhs)
    end

    # equal and of the same type?
    def eql?(rhs)
      self == rhs
    end

    # ordering
    def <=>(rhs)
      return nil unless rhs.is_a?(::Obfusk::ADT) &&
                        self.class.superclass == rhs.class.superclass
      k = self.class.superclass.constructors.keys
      ctor != rhs.ctor ? k.index(ctor_name) <=> k.index(rhs.ctor_name) :
        _compare_data(rhs)
    end

    def _eq_data(rhs)
      data == rhs.data
    end

    def _compare_data(rhs)
      data.values_at(*ctor_keys) <=> rhs.data.values_at(*ctor_keys)
    end

    # pattern matching
    def match(opts)
      unless (ck = self.class.superclass.constructors.keys.sort) ==
             (ok = opts.keys.sort)
        raise ArgumentError,
          "constructors do not match (#{ok} for #{ck})"
      end
      opts[ctor_name][self]
    end

    # to string
    def to_s
      "#<#{self.class.superclass.name || '#ADT'}.#{ctor_name}: #{data}>"
    end

    # to string
    def inspect
      to_s
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
