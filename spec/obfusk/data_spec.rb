# --                                                            ; {{{1
#
# File        : obfusk/data_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-19
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/data'

o = Obfusk

describe 'obfusk/data' do

  context 'merge' do
    it 'merges hashes' do
      h = {x:1}
      expect(o.merge(h,y:2)).to eq({x:1,y:2})
      expect(o.merge(h,x:2)).to eq({x:2})
      expect(h).to              eq({x:1})
    end
    it 'merges arrays' do
      a = [1,2,3]
      expect(o.merge(a,3 => 99)).to eq([1,2,3,99])
      expect(o.merge(a,1 => 88)).to eq([1,88,3])
      expect(a).to                  eq([1,2,3])
    end
  end

  context 'merge!' do
    it 'merges hashes destructively' do
      h1 = {x:1}; h2 = h1.dup
      expect(o.merge!(h1,y:2)).to   eq({x:1,y:2})
      expect(o.merge!(h2,x:2)).to   eq({x:2})
      expect(h1).to                 eq({x:1,y:2})
      expect(h2).to                 eq({x:2})
    end
    it 'merges arrays destructively' do
      a1 = [1,2,3]; a2 = a1.dup
      expect(o.merge!(a1,3 => 99)).to eq([1,2,3,99])
      expect(o.merge!(a2,1 => 88)).to eq([1,88,3])
      expect(a1).to                   eq([1,2,3,99])
      expect(a2).to                   eq([1,88,3])
    end
  end

  context 'symbolic_hash' do
    it 'is symbolic' do
      x = o.symbolic_hash x: 99, 'y' => 88, 123 => 77
      expect(x[:x ]).to eq(99)
      expect(x['x']).to eq(nil)
      expect(x[:y ]).to eq(88)
      expect(x['y']).to eq(88)
      expect(x[:z ]).to eq(nil)
      expect(x['z']).to eq(nil)
      expect(x[123]).to eq(77)
      expect(x[456]).to eq(nil)
    end
  end

  context 'symbolic_nested_hashes' do
    it 'is nestedly symbolic' do
      x = o.symbolic_nested_hashes [1, { x: [2, { 'y' => 42 }] } ]
      expect(x[1][:x ]).to          eq([2, { 'y' => 42 }])
      expect(x[1]['x']).to          eq(nil)
      expect(x[1][:x ][1][:y ]).to  eq(42)
      expect(x[1][:x ][1]['y']).to  eq(42)
    end
  end

  context 'get_in' do
    it 'gets nested key' do
      x = { x: { y: 0 }, z: [1,2,3] }
      expect(o.get_in x, :x, :y).to         eq(0)
      expect(o.get_in x, :z, 2).to          eq(3)
      expect(o.get_in x, :X, 2).to          eq(nil)
      expect(o.get_in(x, :X, 2) { 42 }).to  eq(42)
    end
  end

  context 'modify_in' do
    it 'modifies nested key' do
      x = { x: { y: 0 }, z: [1,2,3] }
      expect(o.modify_in(x, :x, :y) { |v| v + 1 }).to \
        eq({ x: { y: 1 }, z: [1,2,3] })
      expect(o.modify_in(x, :z, 1) { |v| v + 11 }).to \
        eq({ x: { y: 0 }, z: [1,13,3] })
      expect(o.modify_in(x, :z) { |v| v + [99] }).to \
        eq({ x: { y: 0 }, z: [1,2,3,99] })
      expect(o.modify_in(x, :x, :X) { |v| v.merge a: 42 }).to \
        eq({ x: { y: 0, X: { a: 42 } }, z: [1,2,3] })
    end
  end

  context 'modify_in!' do
    it 'modifies nested key destructively' do
      x = { x: { y: 0 }, z: [1,2,3] }
      y = { x: { y: 1, X: { a: 42 } }, z: [1,13,3,99] }
      expect(o.modify_in!(x, :x, :y) { |v| v + 1 }).to \
        eq({ x: { y: 1 }, z: [1,2,3] })
      expect(o.modify_in!(x, :z, 1) { |v| v + 11 }).to \
        eq({ x: { y: 1 }, z: [1,13,3] })
      expect(o.modify_in!(x, :z) { |v| v + [99] }).to \
        eq({ x: { y: 1 }, z: [1,13,3,99] })
      expect(o.modify_in!(x, :x, :X) { |v| v.merge a: 42 }).to eq(y)
      expect(x).to eq(y)
    end
  end

  context 'nested_objects' do
    it 'gets nested objects' do
      x = { x: { y: 0 }, z: [1,2,3] }
      expect(o.nested_objects(x, :x, :y)).to eq([x, x[:x], x[:x][:y]])
      expect(o.nested_objects(x, :x, :z)).to eq([x, x[:x], {}])
    end
  end

  context 'set_in' do
    it 'sets nested key' do
      x = { x: { y: 0 }, z: [1,2,3] }
      expect(o.set_in(x, :x, :y, 99)).to eq({ x: { y: 99 }, z: [1,2,3] })
      expect(x).to eq({ x: { y: 0 }, z: [1,2,3] })
    end
  end

  context 'set_in!' do
    it 'sets nested key destructively' do
      x = { x: { y: 0 }, z: [1,2,3] }
      expect(o.set_in!(x, :x, :y, 99)).to eq({ x: { y: 99 }, z: [1,2,3] })
      expect(x).to eq({ x: { y: 99 }, z: [1,2,3] })
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
