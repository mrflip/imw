# -*- coding: utf-8 -*-
require 'rubygems'
require 'active_support'
require 'uuidtools'

module Scrub
  class Generic
    # A regular expression character group
    # (a bunch of characters ready to drop into /[#{validator}]*/)
    # whitelisting allowed characters
    #
    # Must be overridden in child class
    class_inheritable_accessor :validator

    # Sentence fragment for error message on failed validation.
    class_inheritable_accessor :complaint
    self.complaint = "has characters I can't understand"

    # Proc or string or anything that can be 2nd arg to gsub
    # to sanitize
    class_inheritable_accessor :replacer
    self.replacer  = '-'

    # A regular expression to sanitize objects
    # if unset or nil, the validator char group
    class_inheritable_accessor :sanitizer

    # unless overridden or set expressly, just use the
    # validator
    def sanitizer
      @sanitizer || self.validator
    end

    def sanitize str
      str = str.to_s
      str.gsub(%r{([^#{validator.to_s}]+)}u, replacer)
    end

    def valid? str
      %r{\A([#{validator.to_s}]*)\z}u.match(str)
    end
  end

  #
  # A permissive, ASCII-only name string - no control chars, newlines, backslash
  # or <> angle brackets
  #
  class Title < Scrub::Generic
    self.complaint = "should only contain basic keyboard characters (and should not use \\ &lt; or &gt;)."
    self.validator = %r{a-zA-Z0-9_ ~\!@#\$%\^&\*\(\)\-\+=;\:'"`\[\]\{\}\|,\?\.\/}u
  end

  #
  # A permissive, ASCII-only name string - no control chars, newlines, backslash
  # or <> angle brackets
  #
  class UnicodeTitle < Scrub::Title
    self.complaint  = "should only contain keyboard characters (and should not use \\ &lt; or &gt;)."
    self.validator  = %r{[:alpha:][:digit:]#{Scrub::Title.validator}}u
  end

  #
  # Visible characters and spaces (i.e. anything except control characters, etc.)
  #
  class FreeText < Scrub::Generic
    self.complaint  = "should not contain control characters or that kind of junk."
    self.validator  = %r{[:print:]\n\t}u
  end

  module BeginsWithAlpha
    mattr_accessor :slug
    self.slug = 'x'
    # prepend #{slug}#{replacer} to the string if it starts with non-alpha.
    # so, for instance '23jumpstreet' => 'x_23jumpstreet'
    def sanitize_with_begins_with_alpha str
      str = sanitize_without_begins_with_alpha str
      str = 'x' + replacer + str if (str !~ /^[a-z]/i)  # call at end of chain!
      str
    end
    def valid_with_begins_with_alpha? str
      (str =~ /^[a-z]/i) && valid_without_begins_with_alpha?(str)
    end
    def self.included base
      base.alias_method_chain :sanitize, :begins_with_alpha # unless defined?(base.sanitize_without_begins_with_alpha)
      base.alias_method_chain :valid?,   :begins_with_alpha # unless defined?(base.valid_without_begins_with_alpha?)
    end
  end

  #
  # insist that a string be lowercased.
  #
  module Lowercased
    def sanitize_with_lowercased str
      str = sanitize_without_lowercased str
      str.downcase # call at end of chain!
    end
    def valid_with_lowercase? str
      (str !~ /[[:upper:]]/u) && valid_without_lowercase?(str)
    end
    def self.included base
      base.alias_method_chain :sanitize, :lowercased # unless defined?(base.sanitize_without_lowercased)
      base.alias_method_chain :valid?,   :lowercase  # unless defined?(base.valid_without_lowercase?)
    end
  end

  #
  # start with a letter, and contain only A-Za-z0-9_
  #
  class Identifier < Scrub::Generic
    self.complaint  = "should be an identifier: it should start with a letter, and contain only a-z, 0-9 and '_'."
    self.validator  = %r{a-z0-9_}u
    self.replacer   = '_'
    include Scrub::BeginsWithAlpha
    include Scrub::Lowercased
  end

  #
  # start with a letter, and contain only A-Za-z0-9_
  #
  class Uniqname < Scrub::Generic
    self.complaint  = "should be an identifier: it should start with a letter, and contain only a-z, 0-9 and '_'."
    self.validator  = %r{a-z0-9_}u
    self.replacer   = '_'
    include Scrub::BeginsWithAlpha
    include Scrub::Lowercased
  end

  # UNIQNAME_RE  = %r{\A[a-z][]*\z}i # ascii, not :alpha: etc.
  # UNIQNAME_MSG = "should start with a letter, and contain only characters like a-z0-9_-."
  #
  # # "Domain names are restricted to the ASCII letters a through z
  # # (case-insensitive), the digits 0 through 9, and the hyphen, with some other
  # # restrictions in terms of name length and position of hyphens."
  # # (http://en.wikipedia.org/wiki/Domain_name#Overview)
  # # http://tools.ietf.org/html/rfc1034
  # DOMAIN_RE    = %r{\A[a-z][a-z0-9\-][a-z0-9]\z}i # case insensitive
  # DOMAIN_MSG   = "should look like a domain name."
  # DOMAIN_MORE  = "only letters, digits or hyphens (-), start with a letter and end with a letter or number."
  MSG_EMAIL_BAD      = "should look like an email address (you@somethingsomething.com) and include only letters, numbers and .&nbsp;+&nbsp;-&nbsp;&#37; please."
  RE_EMAIL_NAME      = '[\w\.%\+\-]+'                          # what you actually see in practice
  RE_EMAIL_N_RFC2822 = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
  RE_DOMAIN_HEAD     = '(?:[A-Z0-9\-]+\.)+'
  RE_DOMAIN_TLD      = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RE_EMAIL_OK        = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  RE_EMAIL_RFC2822   = /\A#{RE_EMAIL_N_RFC2822}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i

end
