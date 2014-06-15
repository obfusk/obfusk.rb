# --                                                            ; {{{1
#
# File        : obfusk/adt_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-15
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/adt'

describe 'obfusk/adt' do

  foo = Class.new do
    include Obfusk::ADT
    constructor :Foo
    constructor :Bar, :x, :y
    constructor(:Baz, :z) do |cls, data, values, f|
      { z: data[:z] || 42 }
    end
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
      expect(foo.Foo.ctor_name        ).to eq(:Foo)
      expect(foo.Bar(1,2).ctor_name   ).to eq(:Bar)
      expect(foo.Baz.ctor_name        ).to eq(:Baz)
      expect(foo.Bar(11,17).ctor_keys ).to eq([:x, :y])
      expect(foo.Bar(1,2).x           ).to eq(1)
      expect(foo.Bar(1,2).y           ).to eq(2)
      expect(foo.Baz.z                ).to eq(42)
    end
    it 'handles singletons correctly' do
      expect(foo.Foo.object_id == foo.Foo.object_id).to be true
    end
    it 'pattern-matches' do
      f = -> x { x.match Foo: -> (_) { 1 },
                         Bar: -> (x) { x.x + x.y },
                         Baz: -> (x) { -x.z } }
      expect(f[foo.Foo      ]).to eq(1)
      expect(f[foo.Bar(99,1)]).to eq(100)
      expect(f[foo.Baz(77)  ]).to eq(-77)
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
      expect(foo.Bar(11,22).to_s).to eq('#<<ADT>.Bar: {:x=>11, :y=>22}>')
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
