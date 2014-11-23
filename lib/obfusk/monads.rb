# --                                                            ; {{{1
#
# File        : obfusk/monads.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-17
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/adt'
require 'obfusk/monad'

module Obfusk
  module Monads
    class Identity
      include ADT
      include Monad

      constructor :Identity, :run

      def self.mreturn(x)
        Identity(x)
      end
      def self.bind_pass(m, &b)
        b[m.run]
      end
    end

    class Maybe
      include ADT
      include Monad
      include MonadPlus

      constructor :Nothing
      constructor :Just, :value

      def self.mreturn(x)
        Just(x)
      end
      def self.bind_pass(m, &b)
        m.match Nothing:  ->(_) { Nothing()  },
                Just:     ->(x) { b[x.value] }
      end
      def self.zero
        Nothing()
      end
      def self.lazy_plus(m, k)
        m.match Nothing:  ->(_) { k._ },
                Just:     ->(_) { m   }
      end
    end

    class Either
      include ADT
      include Monad

      constructor :Left , :value
      constructor :Right, :value

      def self.mreturn(x)
        Right(x)
      end
      def self.bind_pass(m, &b)
        m.match Left:   ->(_) { m },
                Right:  ->(x) { b[x.value] }
      end
    end

    class State
      include ADT
      include Monad

      class Pair
        include ADT
        constructor :Pair, :value, :state
      end

      Pair.import_constructors self, false

      constructor :State, :run

      # construct a state monad computation from a function (or block)
      def self.state(f = nil, &b)
        State f || b
      end

      # evaluate response with the given initial state and return the
      # final value, discarding the final state
      def self.eval(m, s)
        m.run[s].value
      end

      # evaluate response with the given initial state and return the
      # final state, discarding the final value
      def self.exec(m, s)
        m.run[s].state
      end

      # execute action on a state modified by applying a function (or
      # block)
      def self.with(m, f = nil, &b)
        state { |s| m.run[(f || b)[s]] }
      end

      # get the state
      def self.get
        state { |s| Pair s, s }
      end

      # set the state
      def self.put(s)
        state { |_| Pair nil, s }
      end

      # modify the state by applying a function (or block)
      def self.modify(f = nil, &b)
        state { |s| Pair nil, (f || b)[s] }
      end

      # get a specific component of the state, using a projection
      # function (or block)
      def self.gets(f = nil, &b)
        state { |s| Pair (f || b)[s], s }
      end

      def self.mreturn(x)
        state { |s| Pair x, s }
      end
      def self.bind_pass(m, &b)
        state { |s| x = m.run[s]; b[x.value].run[x.state] }
      end

      %w{ eval exec with }.map(&:to_sym).each do |m|
        define_method(m) do |*a,&b|
          self.class.public_send m, self, *a, &b
        end
      end
    end

    [Maybe, Either].each do |x|
      x.import_constructors self
    end

    [Identity, State].each do |x|
      x.import_constructors self, false
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
