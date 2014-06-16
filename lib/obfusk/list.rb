# --                                                            ; {{{1
#
# File        : obfusk/list.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-16
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/adt'
require 'obfusk/lazy'
require 'obfusk/monad'

module Obfusk
  # Lazy List
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

    class Cons
      # lazy tail
      alias :lazy_tail :tail

      # eager tail
      def tail
        lazy_tail._
      end
    end

    def _eq_data(rhs)
       match  Nil:  -> (_) { true },
              Cons: -> (_) { [head,tail] == [rhs.head,rhs.tail] }
    end

    def _compare_data(rhs)
       match  Nil:  -> (_) { 0 },
              Cons: -> (_) { [head,tail] <=> [rhs.head,rhs.tail] }
    end

    # --

    def each(&b)
      return enum_for :each unless b
      xs = self; while xs != Nil() do b[xs.head]; xs = xs.tail end
    end

    def to_s
      *xs, x = self.class.name.split '::'; n = xs*'::' + '.' + x
      self == Nil() ? "<##{n}>" : "<##{n}(#{head},...)>"
    end

    def to_a
      each.to_a
    end

    # pretend to be lazy (so we don't need Obfusk.eager)
    def _
      self
    end

    # pretend to be lazy (see _)
    def chain(m,*a,&b)
      ::Obfusk.lazy { public_send(m,*a,&b) }
    end

    # --

    # the list of those elements that satisfy the predicate
    def filter(p = nil, &b)
      g = p || b
      match Nil:  -> (_) { Nil() },
            Cons: -> (_) { g[head] ? Cons(head) { tail.filter(g) }
                                   :              tail.filter(g) }
    end

    # the list obtained by applying a function (or block) to each element
    def map(f = nil, &b)
      g = f || b
      match Nil:  -> (_) { Nil() },
            Cons: -> (_) { Cons(g[head]) { tail.map g } }
    end

    # --

    # element at index
    def [](i)
      raise ArgumentError, 'negative index' if i < 0
      j = 0; each { |x| return x if i == j; j += 1 }
      raise ArgumentError, 'index too large'
    end

    # length
    def length
      n = 0; each { n += 1 }; n
    end

    # empty?
    def null
      match Nil: -> (_) { true }, Cons: -> (_) { false }
    end
    alias :null?  :null
    alias :empty? :null

    # --

    # def last
    # def init

    # --

    # append two lists
    def append(ys)
      match Nil:  -> (_) { ys._ },
            Cons: -> (_) { Cons(head) { tail.append ys } }
    end

    # def reverse

    # -- Reducing lists (folds) --

    # def foldl
    # def foldl1

    # foldr, applied to a binary operator, a starting value (typically
    # the right-identity of the operator), and a list, reduces the
    # list using the binary operator, from right to left:
    #
    # ```haskell
    # foldr f z [x1, x2, ..., xn] == x1 `f` (x2 `f` ... (xn `f` z)...)
    # ```
    #
    # NB: because ruby is not lazy, the secons argument of the binary
    # operator is lazy and must be treated as such.
    def foldr(z, f = nil, &b)
      g = f || b
      match Nil:  -> (_) { z },
            Cons: -> (_) { g[head, tail.chain(:foldr, z, g)] }
    end

    # def foldr1

    # -- Special folds --

    # def and
    # def or
    # def any

    # concatenate a list of lists
    def concat
      foldr(Nil()) { |x,ys| x.append ys }
    end

    # def concatMap

    # def sum
    # def product
    # def maximum
    # def minimum

    # -- Building lists --

    # def scanl
    # def scanl1
    # def scanr
    # def scanr1

    # -- Infinite lists --

    # def iterate
    # def repeat
    # def replicate
    # def cycle

    # -- Sublists --

    # the prefix of length n (or the list itself if n > length)
    def take(n)
      return Nil() if n <= 0
      match Nil:  -> (_) { Nil() },
            Cons: -> (_) { Cons(head) { tail.take(n - 1) } }
    end

    # def drop
    # def splitAt
    # def takeWhile
    # def dropWhile
    # def span
    # def break

    # -- Searching lists --

    # def elem
    # def notElem
    # def lookup

    # -- Zipping and unzipping lists --

    # def zip
    # def zip3

    # combine parallel elements of two lists using a binary operator
    def zipWith(ys, f = nil, &b)
      g = f || b
      self == Nil() || ys._ == Nil() ? Nil() :
        Cons(g[head, ys._.head]) { tail.zipWith(ys._.tail, g) }
    end

    # def zipWith3
    # def unzip
    # def unzip3

    # -- Functions on strings --

    # def lines
    # def words
    # def unlines
    # def unwords

    # -- Monad --

    def self.mreturn(x)
      Cons x, Nil()
    end

    # TODO
    # def self.bind_pass(m, &b)
    #   m.match Nil:  -> (_) { m },
    #           Cons: -> (_) {}     # concat (map f m)
    # end
  end

  List.import_constructors self

  # create a list from its items; pass a block to add a lazy tail
  def self.List(*xs, &b)
    b && xs.length == 1 ? Cons(xs.first, &b)  :
    b && xs.empty?      ? b._                 :
    xs.empty?           ? Nil()               :
    Cons(xs.first) { List(*xs.drop(1), &b) }
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
