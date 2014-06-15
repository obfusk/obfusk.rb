# --                                                            ; {{{1
#
# File        : obfusk/monads.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-15
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/adt'
require 'obfusk/monad'

module Obfusk
  class Maybe
    include ADT
    include Monad
    include MonadPlus

    constructor :Nothing
    constructor :Just, :value

    def self.mreturn(x)
      Just(x)
    end
    def self.bind_pass(m, &b)
      m.match Nothing:  -> (_) { Nothing()  },
              Just:     -> (x) { b[x.value] }
    end
  end

  class Either
    include ADT
    include Monad
    include MonadPlus

    constructor :Left , :value
    constructor :Right, :value

    def self.mreturn(x)
      Right(x)
    end
    def self.bind_pass(m, &b)
      m.match Left:   -> (_) { m },
              Right:  -> (x) { b[x.value] }
    end
  end

  [Maybe, Either].each { |x| x.import_constructors self }

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :