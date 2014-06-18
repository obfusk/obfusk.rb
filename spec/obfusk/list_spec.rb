# --                                                            ; {{{1
#
# File        : obfusk/list_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-18
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
    it 'compares' do
      expect(Obfusk.List()).to      be < Obfusk.List(1)
      expect(Obfusk.List(1,2,3)).to be < Obfusk.List(1,2,4)
      expect(Obfusk.List(1,2,3)).to be > Obfusk.List(1,2,2)
      expect(Obfusk.List(1,2,3)).to be > Obfusk.List(1,2)
    end
    it 'iterates' do
      x = 0; l2.each { |y| x += y }; expect(x).to eq(10)
    end
    it 'converts to array' do
      expect(l2.to_a).to eq([1,2,3,4])
    end
    it 'converts to string' do
      expect(Obfusk.Nil.to_s).to eq('<#Obfusk::List.Nil>')
      expect(l2.to_s).to eq('<#Obfusk::List.Cons(1,...)>')
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
      it 'indexes' do
        expect( l2[2]   ).to eq(3)
        expect{ l2[-1]  }.to raise_error(ArgumentError, 'negative index')
        expect{ l2[4]   }.to raise_error(ArgumentError, 'index too large')
      end
      it 'has length' do
        expect(l2.length).to eq(4)
      end
      it 'can be empty? (null?, null)' do
        expect(l2.empty?).to        be false
        expect(l3.empty?).to        be false
        expect(Obfusk.Nil.null).to  be true
        expect(l1.null?).to         be false
      end
      # ...
      it 'appends' do
        expect(Obfusk.Nil.append(Obfusk.Nil)).to  eq(Obfusk.Nil)
        expect(l2.append(l1).to_a).to             eq([1,2,3,4,1])
        expect(l2.append(l3).take(10).to_a).to    eq([1,2,3,4,0,1,2,4,0,1])
      end
      # ...
      it 'foldrs' do
        expect(l2.foldr(0) { |x,y| x - y._ }).to eq(1 - (2 - (3 - (4 - 0))))
      end
      # ...
      it 'concats' do
        expect(Obfusk.List(l2,l2,l2).concat.to_a).to eq([1,2,3,4]*3)
      end
      # ...
      it 'takes' do
        expect(l3.take(10).to_a).to eq([0,1,2,4]*2 + [0,1])
      end
      # ...
      it 'can zipWith' do
        expect(l2.zipWith(l3, &:+).to_a).to eq([1,3,5,8])
      end

      # ... TODO ...
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
