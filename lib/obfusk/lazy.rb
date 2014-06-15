# --                                                            ; {{{1
#
# File        : obfusk/lazy.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-15
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

module Obfusk
  # lazy evaluation (thunk)
  def self.lazy(x = nil, &b)
    return x if x.respond_to?(:__obfusk_lazy__?) && x.__obfusk_lazy__?
    f = b ? b : -> { x }; v = nil; e = false
    g = -> () { unless e then v = f[]; e = true end; v }
    g.define_singleton_method(:__obfusk_lazy__?) { true }
    g.define_singleton_method(:_) { g[] }
    g.define_singleton_method(:chain) do |m,*a,&b|
      ::Obfusk::lazy { g[].public_send(m,*a,&b) }
    end
    g
  end

; # eager: evaluate if lazy, just return if not
  def self.eager(x)
    x.respond_to?(:__obfusk_lazy__?) && x.__obfusk_lazy__? ? x._ : x
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
