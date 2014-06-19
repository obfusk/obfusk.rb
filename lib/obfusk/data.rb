# --                                                            ; {{{1
#
# File        : obfusk/data.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-19
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

nil

class Array
  # merge array; see Obfusk.merge
  def __obfusk_merge__(h = {})
    dup.__obfusk_merge__! h
  end

  # merge! array; see Obfusk.merge
  def __obfusk_merge__!(h = {})
    h.each_pair { |k,v| self[k] = v }; self
  end
end

module Obfusk
  # -- data structures --

  # merge anything that responds to `.__obfusk_merge__` or `.merge`
  def self.merge(x, h = {})
    x.respond_to?(:__obfusk_merge__) ? x.__obfusk_merge__(h) : x.merge(h)
  end

  # merge anything that responds to `.__obfusk_merge__!` or `.merge!`
  def self.merge!(x, h = {})
    x.respond_to?(:__obfusk_merge__!) ? x.__obfusk_merge__!(h) : x.merge!(h)
  end

  # hash w/ indifferent access (i.e. symbol or string does not matter)
  def self.indifferent_hash(h = {}, &b)
    x = Hash.new do |h,k|
      case k
      when Symbol ; h.fetch k.to_s  , nil
      when String ; h.fetch k.to_sym, nil
      else          nil
      end
    end
    h.each { |k,v| x[k] = b ? b[v] : v }; x
  end

  # indifferent nested hashes/arrays/...
  def self.indifferent_nested_hashes(x)
    case x
    when Hash ; indifferent_hash(x) { |v| indifferent_nested_hashes v }
    when Array; x.map { |v| indifferent_nested_hashes v }
    else        x
    end
  end

  # -- nested data structures --

  # get nested key in nested datastructure
  def self.get_in(o, *ks, &b)
    ks.each { |k| o = o.fetch(k) { return b ? b[] : nil } }; o
  end

  # swap value for nested key in nested datastructure; autovivifies
  # missing keys as hashes
  # @return a new datastructure
  def self.modify_in(o, k, *ks, &b)
    ks_ = [k] + ks; os = nested_objects o, *ks_; o_ = b[os.pop]
    ks_.reverse.each { |k| o_ = merge(os.pop, k => o_) }; o_
  end

  # swap value for nested key in nested datastructure; autovivifies
  # missing keys as hashes
  # @return modified datastructure
  def self.modify_in!(o, k, *ks, &b)
    ks_ = [k] + ks; os = nested_objects o, *ks_; o_ = b[os.pop]
    ks_.reverse.each { |k| o_ = merge!(os.pop, k => o_) }; o_
  end

  # get stack of objects for nested key in nested datastructure;
  # autovivifies missing keys as hashes
  def self.nested_objects(o, *ks)
    [o] + ks.map { |k| o = o.fetch(k) { {} } }
  end

  # set value for nested key in nested datastructure
  # @return a new datastructure
  def self.set_in(o, *ks, v)
    modify_in(o, *ks) { |_| v }
  end

  # set value for nested key in nested datastructure
  # @return modified datastructure
  def self.set_in!(o, *ks, v)
    modify_in!(o, *ks) { |_| v }
  end

  # -- ... --

  # ...
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
