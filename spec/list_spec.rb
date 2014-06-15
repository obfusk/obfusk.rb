# --                                                            ; {{{1
#
# File        : obfusk/list_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-15
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/list'

describe 'obfusk/list' do

  context 'List' do
    l1 = Obfusk.Cons(1) { Obfusk.Nil }
    l2 = Obfusk.List(1,2,3,4)
    l3 = Obfusk.List(0,1,2,4) { l3 }

    it 'has Nil' do
      expect(Obfusk.Nil).to eq(Obfusk.Nil)
    end
    it 'has Cons' do
      expect(l1.to_a).to eq([1])
    end
    it 'has head & tail' do
      expect(l1.head).to eq(1)
      expect(l1.lazy_tail).to be_a(Proc)
      expect(l1.tail).to eq(Obfusk.Nil)
    end
    it 'has .to_each' do
      x = 0; l2.each { |y| x += y }; expect(x).to eq(10)
    end
    it 'pretends to be lazy' do
      expect(l1._).to be (l1)
    end
    it 'chains' do
      expect(l1.chain(:tail)._).to be(l1.tail)
    end

    context 'has list functions and' do
      it 'filters' do
        expect(l2.filter { |x| x.even? }).to eq(Obfusk.List(2,4))
      end
      it 'maps' do
        expect(l2.map { |x| x*x }.to_a).to eq([1,4,9,16])
      end

      # ... TODO ...
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
