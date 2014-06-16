# --                                                            ; {{{1
#
# File        : obfusk/atom.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-16
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'thread'

module Obfusk
  class Atom
    attr_reader   :value
    alias :_      :value
    alias :deref  :value

    # new Atom with value
    def initialize(value)
      @mutex = Mutex.new
      @value = value
    end

    # calls block with value; uses a mutex to synchronize
    def with_value(&b)
      @mutex.synchronize { b[value] }
    end

    # atomically swaps the value to be `b[oldvalue]`; uses
    # `with_value`
    def swap!(&b)
      with_value { |v| @value = b[v] }
    end
  end

  # create an Atom
  def self.atom(value)
    Atom.new value
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
