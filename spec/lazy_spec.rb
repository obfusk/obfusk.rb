# --                                                            ; {{{1
#
# File        : obfusk/lazy_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-15
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/lazy'

describe 'obfusk/lazy' do

  context 'lazy' do
    it 'seems to be lazy' do
      x = 0; l = Obfusk.lazy { x += 1 }
      expect(x    ).to eq(0)
      expect(l._  ).to eq(1)
      expect(x    ).to eq(1)
      expect(l._  ).to eq(1)
      expect(x    ).to eq(1)
    end
    it 'does not double lazyness' do
      l = Obfusk.lazy { 42 }
      expect(Obfusk.lazy l).to be(l)
    end
    it 'chains' do
      x = 0; y = 0
      c = Class.new do
        define_method(:initialize)  { x += 1 }
        define_method(:foo)         { y += 1 }
      end
      l = Obfusk.lazy { c.new }
      expect(x).to    eq(0)
      expect(y).to    eq(0)
      l2 = l.chain(:foo)
      expect(x).to    eq(0)
      expect(y).to    eq(0)
      expect(l2._).to eq(1)
      expect(x).to    eq(1)
      expect(y).to    eq(1)
    end
  end

  context 'lazy?' do
    it 'works with non-lazy objects' do
      expect(Obfusk.lazy?(Object.new)).to be false
    end
    it 'works with lazy objects' do
      expect(Obfusk.lazy?(Obfusk.lazy { 42 })).to be true
    end
  end

  context 'eager' do
    x = Object.new
    it 'works with non-lazy objects' do
      expect(Obfusk.eager(x)).to be(x)
    end
    it 'works with lazy objects' do
      l = Obfusk.lazy { x }
      expect(Obfusk.eager(l)).to be(x)
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
