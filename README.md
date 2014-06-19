[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-06-19

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.1.3

[]: }}}1

[![Gem Version](https://badge.fury.io/rb/obfusk.png)](https://badge.fury.io/rb/obfusk)

## Description

  obfusk.rb - functional programming library for ruby

## Examples

[]: {{{1

```ruby
require 'obfusk/adt'

class Foo
  include Obfusk::ADT
  constructor :Bar
  constructor :Baz, :value
end

x = Foo.Bar
y = Foo.Baz 99

y.value # => 99

x.match Bar: -> (_) { "it's a bar!" },
        Baz: -> (z) { "it's a baz with value: #{z.value}" }
# => "it's a bar!"
```

[]: }}}1

[]: {{{1

```ruby
require 'obfusk/atom'

x = Obfusk.atom 42
x._ # => 42
10.times { x.swap! { |v| v + 1 } }
x._ # => 53
```

[]: }}}1

[]: {{{1

```ruby
require 'obfusk/data'

Obfusk.merge([1,2,3], 1 => 99)
# => [1,99,3]

x = { x: { y: 0 }, z: [1,2,3] }

Obfusk.get_in x, :x, :y
# => 0

Obfusk.modify_in(x, :x, :y) { |v| v + 1 }
# => { x: { y: 1 }, z: [1,2,3] }

Obfusk.set_in(x, :z, 1, 99)
# => { x: { y: 0 }, z: [1,99,3] }
```

[]: }}}1

[]: {{{1

```ruby
require 'obfusk/lazy'

x = Obfusk.lazy { some_expensive_computation_that_returns_42 }
x._ # => 42 (expensive computation not run until now)
x._ # => 42 (cached)

y = Obfusk.lazy { Foo.new 42 }
z = y.chain(:value)
z._ # => 42 (.new and .value not run until now)

Obfusk.eager(lazy_or_not) # => value
```

[]: }}}1

[]: {{{1

```ruby
require 'obfusk/list'

fibs = Obfusk.List(0,1) { fibs.zipWith(fibs.tail, &:+) }

fibs == Obfusk.Nil
# => false

fibs.take(10).to_a
# => [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

fibs.map { |x| x*x } .take(10).to_a
# => [0, 1, 1, 4, 9, 25, 64, 169, 441, 1156]
```

[]: }}}1

[]: {{{1

```ruby
require 'obfusk/monad'

class Foo
  include Obfusk::Monad
  def self.mreturn(x)
    # ...
  end
  def self.bind_pass(m, &b)
    # ...
  end
end

f = -> x { '...' }
g = -> y { '...' }

Foo.new('...').pipeline f, g
```

[]: }}}1

[]: {{{1

```ruby
require 'obfusk/monads'
ms = Obfusk::Monads

x = ms.Nothing
y = ms.Just 42

x.bind(y)
# => ms.Nothing

ms.Left "oops"
ms.Right 37
```

[]: }}}1

...

## Specs & Docs

```bash
$ rake spec
$ rake coverage
$ rake docs
```

## TODO

  * more lists operations
  * ...

<!--
https://clojure.github.io/clojure/#clojure.core
http://hackage.haskell.org/package/base-4.7.0.0/docs/Prelude.html
http://obfusk.org/obfusk.coffee
-->

## License

  LGPLv3+ [1].

## References

  [1] GNU Lesser General Public License, version 3
  --- http://www.gnu.org/licenses/lgpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
