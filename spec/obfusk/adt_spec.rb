# --                                                            ; {{{1
#
# File        : obfusk/adt_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-17
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/adt'

describe 'obfusk/adt' do

  ctors = -> c { c.constructors.values.map { |x| x[:ctor] } }

  foo = Class.new do
    include Obfusk::ADT
    constructor :Foo
    constructor :Bar, :x, :y
    constructor(:Baz, :z) do |cls, data, values, f|
      { z: data[:z] || 42 }
    end
  end

  bar = Class.new(foo) do
    constructor :Qux, :ok?
  end

  baz = Class.new(bar) do
    constructor :Quux
  end

  context 'ADT foo' do
    it 'has 3 constructors with the expected names' do
      expect(foo.constructors.keys.sort).to \
        eq(%w{ Foo Bar Baz }.map(&:to_sym).sort)
    end
    it 'has constructors with the expected types' do
      expect(foo.Foo        ).to be_a(foo::Foo)
      expect(foo.Bar(11,17) ).to be_a(foo::Bar)
      expect(foo.Baz(99)    ).to be_a(foo::Baz)
      expect(foo.Foo        ).to be_a(foo)
    end
    it 'has constructors with the expected attrs' do
      expect(foo.Foo.__adt_ctor_name__        ).to eq(:Foo)
      expect(foo.Bar(1,2).__adt_ctor_name__   ).to eq(:Bar)
      expect(foo.Baz.__adt_ctor_name__        ).to eq(:Baz)
      expect(foo.Bar(11,17).__adt_ctor_keys__ ).to eq([:x, :y])
      expect(foo.Bar(1,2).x                   ).to eq(1)
      expect(foo.Bar(1,2).y                   ).to eq(2)
      expect(foo.Baz.z                        ).to eq(42)
    end
    it 'has record constructors' do
      expect(foo.new :Foo).to             eq(foo.Foo)
      expect(foo.new :Bar, y: 1, x: 2).to eq(foo.Bar 2, 1)
      expect(foo.new :Baz, z: 99).to      eq(foo.Baz 99)
    end
    it 'clones' do
      x = foo.Bar(1,2)
      expect(x.clone).to        be(x)
      expect(x.clone(y: 99)).to eq(foo.Bar(1,99))
    end
    it 'handles singletons correctly' do
      expect(foo.Foo.object_id == foo.Foo.object_id).to be true
    end
    it 'pattern-matches' do
      f = -> x { x.match Foo: ->(_) { 1 },
                         Bar: ->(x) { x.x + x.y },
                         Baz: ->(x) { -x.z } }
      expect(f[foo.Foo      ]).to eq(1)
      expect(f[foo.Bar(99,1)]).to eq(100)
      expect(f[foo.Baz(77)  ]).to eq(-77)
    end
    it 'fails matching with wrong keys' do
      expect{ foo.Foo.match(Foo: ->(_) { 99 }) }.to \
        raise_exception(ArgumentError, /constructors do not match/)
      expect{ foo.Foo.match(Foo: nil, Bar: nil, Baz: nil, Qux: nil) }.to \
        raise_exception(ArgumentError, /constructors do not match/)
    end
    it 'has proper equality' do
      expect(foo.Foo).to          eq(foo.Foo)
      expect(foo.Foo).to_not      eq(foo.Bar(1,2))
      expect(foo.Bar(1,2)).to     eq(foo.Bar(1,2))
      expect(foo.Bar(2,1)).to_not eq(foo.Bar(1,2))
    end
    it 'has proper ordering' do
      expect(foo.Foo).to_not    be > foo.Foo
      expect(foo.Foo).to_not    be < foo.Foo
      expect(foo.Foo).to        be < foo.Bar(1,2)
      expect(foo.Bar(11,22)).to be > foo.Foo
      expect(foo.Bar(11,22)).to be > foo.Bar(11,21)
    end
    it 'has proper to_s' do
      expect(foo.Bar(11,22).to_s).to eq('#<#ADT.Bar: {:x=>11, :y=>22}>')
    end

    context 'inherits properly and' do
      it 'has its own constructors' do
        expect(ctors[foo] & ctors[bar]).to eq([])
        expect(ctors[foo] & ctors[baz]).to eq([])
        expect(ctors[bar] & ctors[baz]).to eq([])
      end
      it 'has all expected constructors' do
        expect(foo.constructors.keys).to eq([:Foo,:Bar,:Baz])
        expect(bar.constructors.keys).to eq([:Foo,:Bar,:Baz,:Qux])
        expect(baz.constructors.keys).to eq([:Foo,:Bar,:Baz,:Qux,:Quux])
      end
      it 'matches properly' do
        f = -> x { x.match Foo:  ->(_) { 1  },
                           Bar:  ->(_) { 2  },
                           Baz:  ->(_) { 3  } }
        g = -> x { x.match Foo:  ->(_) { 4  },
                           Bar:  ->(_) { 5  },
                           Baz:  ->(_) { 6  },
                           Qux:  ->(_) { 7  } }
        h = -> x { x.match Foo:  ->(_) { 8  },
                           Bar:  ->(_) { 9  },
                           Baz:  ->(_) { 10 },
                           Qux:  ->(_) { 11 },
                           Quux: ->(_) { 12 } }
        expect(f[foo.Foo]   ).to eq(1)
        expect(g[bar.Qux 99]).to eq(7)
        expect(h[baz.Quux]  ).to eq(12)
        expect { f[bar.Foo] }.to \
          raise_exception(ArgumentError, /constructors do not match/)
        expect { g[baz.Foo] }.to \
          raise_exception(ArgumentError, /constructors do not match/)
        expect { h[foo.Foo] }.to \
          raise_exception(ArgumentError, /constructors do not match/)
        expect { h[bar.Foo] }.to \
          raise_exception(ArgumentError, /constructors do not match/)
      end
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
