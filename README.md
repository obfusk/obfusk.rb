[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-06-16

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.1.1

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

x = Foo.Bar()
y = Foo.Baz 99

puts y.value # => 99
```

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

```ruby
require 'obfusk/monad'

class Foo
  include Obfusk::Monad
  def self.return(x)
    # ...
  end
  def self.bind_pass(m, &b)
    # ...
  end
end

f = -> x { '...' }
g = -> y { '...' }

Foo.pipeline Foo.new('...'), f, g
```

```ruby
require 'obfusk/monads'

x = Obfusk.Nothing
y = Obfusk.Just 42

x.bind(y)
# => Obfusk.Nothing

Obfusk.Left "oops"
Obfusk.Right 37
```

...

[]: }}}1

## Specs & Docs

```bash
$ rake spec
$ rake docs
```

## TODO

  * more lists operations
  * more stuff from obfusk.coffee
  * ...

## License

  LGPLv3+ [1].

## References

  [1] GNU Lesser General Public License, version 3
  --- http://www.gnu.org/licenses/lgpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
