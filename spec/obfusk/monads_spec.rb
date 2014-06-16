# --                                                            ; {{{1
#
# File        : obfusk/monads_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-16
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/monads'

m = Obfusk::Maybe
e = Obfusk::Either

describe 'obfusk/monads' do

  context 'Maybe' do
    it 'returns' do
      expect(m.mreturn(42)).to eq(m.Just(42))
    end
    it 'bind_passes' do
      expect(m.Nothing  .bind { |x|  m.Just x + 1 }).to eq(m.Nothing)
      expect(m.Just(42) .bind -> x { m.Just x + 1 }).to eq(m.Just(43))
    end
    it 'bind_discards' do
      expect(m.Nothing  .bind(m.Just(99))).to eq(m.Nothing)
      expect(m.Just(42) .bind(m.Just(99))).to eq(m.Just(99))
    end
    it 'fmaps' do
      expect(m.Nothing.fmap { |x| x + 1 }).to eq(m.Nothing)
      expect(m.Just(1).fmap { |x| x + 1 }).to eq(m.Just(2))
    end
    it 'joins' do
      expect(m.mreturn(m.mreturn(42)).join).to eq(m.Just(42))
    end
    it 'pipelines lazily' do
      l = []
      a = -> x { l << :a; m.return x + 1   }
      b = -> x { l << :b; m.return x * 2   }
      c = -> x { l << :c; m.zero           }
      d = -> x { l << :d; m.return x ** 3  }
      expect(m.return(1).pipeline(a,b,d)).to eq(m.Just(64))
      expect(l).to eq([:a,:b,:d])
      expect(m.return(1).pipeline(a,b,c,d)).to eq(m.Nothing)
      expect(l).to eq([:a,:b,:d,:a,:b,:c])
    end
    it 'pipelines w/ non-procs' do
      expect(m.return(1).pipeline(
        m.Just(2), -> x { m.return x * x }
      )).to eq(m.Just(4))
    end
    it 'sequences' do
      expect(
        m.sequence(m.return(42), m.return(37), m.return(99))
      ).to eq(m.return [42,37,99])
    end
    it 'sequence_s' do
      # TODO: test w/ side-effects
      expect(
        m.return(1).sequence_ m.return(2), m.return(3)
      ).to eq(m.return nil)
    end
    it 'can be zero' do
      expect(m.zero).to eq(m.Nothing)
    end
    it 'plusses' do
      # TODO: test lazyness
      expect(m.zero.plus m.zero       ).to eq(m.Nothing)
      expect(m.Nothing.plus m.Just(42)).to eq(m.Just 42)
      expect(m.Just(1).plus m.Just(2) ).to eq(m.Just 1)
      expect(m.Just(1).plus m.Nothing ).to eq(m.Just 1)
    end
  end

  context 'Either' do
    it 'returns' do
      expect(e.mreturn(42)).to eq(e.Right(42))
    end
    it 'bind_passes' do
      expect(e.Left('hi!').bind { |x| e.Right x + 1 }).to eq(e.Left('hi!'))
      expect(e.Right(42)  .bind { |x| e.Right x + 1 }).to eq(e.Right(43))
    end
    it 'bind_discards' do
      expect(e.Left('hi!').bind(e.Right(99))).to eq(e.Left('hi!'))
      expect(e.Right(42)  .bind(e.Right(99))).to eq(e.Right(99))
    end
    it 'fmaps' do
      expect(e.Left('hi!').fmap { |x| x + 1 }).to eq(e.Left('hi!'))
      expect(e.Right(1)   .fmap { |x| x + 1 }).to eq(e.Right(2))
    end
    it 'joins' do
      expect(e.mreturn(e.mreturn(42)).join).to eq(e.Right(42))
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
