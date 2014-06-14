# --                                                            ; {{{1
#
# File        : obfusk/list.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-14
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/adt'
require 'obfusk/lazy'
require 'obfusk/monad'

module Obfusk
  class List
    include ADT
    include Monad
    include MonadPlus

    constructor :Nil
    constructor(:Cons, :head, :tail) do |cls, data, values, f|
      v = values.length + (f ? 1 : 0)
      if (k = cls.ctor_keys.length) != v
        raise ArgumentError, "wrong number of arguments (#{v} for #{k})"
      end
      { head: data[:head], tail: f ? ::Obfusk.lazy(&f) :
                                     ::Obfusk.lazy(data[:tail]) }
    end

    def each(&b)
      return enum_for :each unless b
      xs = self; while xs != Nil() do b[xs.head]; xs = xs.tail._ end
    end

    def to_a
      each.to_a
    end

    def _
      self
    end

    # --

    def filter(p = nil, &b)
      g = f || b
      match Nil:  -> (_) { Nil() },
            Cons: -> (x) { p[x] ? Cons(x.head) { x.tail._.filter p  }
                                :                x.tail._.filter(p) }
    end

    def map(f = nil, &b)
      g = f || b
      match Nil:  -> (_) { Nil() },
            Cons: -> (x) { Cons(g[x.head]) { x.tail._.map g } }
    end

    # --

    def [](i)
      raise ArgumentError, 'negative index' if i < 0
      j = 0; each { |x| return x if i == j; j += 1 }
      raise ArgumentError, 'index too large'
    end

    def length
      n = 0; each { n += 1 }; n
    end

    def null
      match Nil:  -> (_) { true }, Cons: -> (x) { false }
    end
    alias :empty? :null

    # --

    def append(ys)
      match Nil:  -> (_) { ys._ },
            Cons: -> (x) { Cons(x.head) { x.tail._.append ys._ } }
    end

    # def reverse

    # --

    # def foldl

    def foldr(z, f = nil, &b)
      g = f || b
      match Nil:  -> (_) { z },
            Cons: -> (x) { g[x.head, ::Obfusk.lazy { x.tail._.foldr(z, g) }] }
    end

    # def and
    # def or
    # def any

    # def concat
    #   foldr(Nil()) { |x,y| x.append y[] } # TODO
    # end

    # def concatMap

    # def sum
    # def product
    # def maximum
    # def minimum

    # --

    # def zipWith(ys, f = nil, &b)
    #   g = f || b
    #   self == Nil() || ys._ == Nil() ? Nil() :
    #     Cons(g[head, ys._.head]) { puts "!WTF" } # ; tail._.zipWith(ys._.tail, g) }
    # end

    # --

    # def last
    # def init

    # --

    # ...

    # --

    def self.mreturn(x)
      Cons x, Nil()
    end

    # TODO
    # def self.bind_pass(m, &b)
    #   m.match Nil:  -> (_) { m },
    #           Cons: -> (x) {}     # concat (map f m)
    # end
  end

  List.import_constructors self

  def self.List(*xs)
    xs.empty? ? Nil() : Cons(xs.first) { List(*xs.drop(1)) }
  end

  def self.cons(*xs, &b)
    if xs.empty?
      b[]
    else
      *ys, x = xs; zs = Cons(x, &b)
      ys.reverse.each { |y| zs = Cons(y, zs) }; zs
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
