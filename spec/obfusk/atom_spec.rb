# --                                                            ; {{{1
#
# File        : obfusk/atom_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-16
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/atom'
require 'thread'
require 'thwait'

describe 'obfusk/atom' do

  context 'Atom' do
    it 'swap!s' do
      a = Obfusk.atom 1
      10.times { a.swap! { |x| x + 1 } }
      expect(a._).to eq(11)
    end
    it 'seems to be threadsafe' do
      a = Obfusk.atom 1; l = []
      t = -> {
        Thread.new { 10.times {
          a.swap! { |v| l << v; v + 1 }
          sleep 0.1
        } }
      }
      t1, t2, t3 = t[], t[], t[]
      ThreadsWait.all_waits t1, t2, t3
      expect(l).to eq((1..30).to_a)
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
