#
# h2. lib/imw/utils/paths.rb -- defines local paths to IMW directories
#
# == About
#
# IMW uses lots of different directories to keep information on data
# and datasets separate.  This module interfaces with the
# configuration files to establish the paths to these IMW directories
# and provides functions and mixins for IMW objects to use to access
# these paths.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils/config'

module IMW

  module Paths

    # Returns the root of workflow `step'
    def self.root_of(step)
      case step
      when :ripd
        IMW::Config::Directories[:ripd]
      when :xtrd
        IMW::Config::Directories[:xtrd]          
      when :mungd
        IMW::Config::Directories[:mungd]
      when :fixd
        IMW::Config::Directories[:fixd]          
      when :pkgd
        IMW::Config::Directories[:pkgd]          
      when :dump
        IMW::Config::Directories[:dump]
      else
        raise ArgumentError.new("The only valid workflow steps and therefore workflow root directories are `:ripd', `:xtrd', `:mungd', `:fixd', `:pkgd', and `:dump'.")
      end
    end

  end

end




module IMWPaths
  DIRS = [
    [:root,      $IMW_ROOT             ],   # set in utils/boot
    [:imw_lib,   :root, 'imw', 'lib'   ],
    [:imw_bin,   :root, 'imw', 'bin'   ],
    [:imw_etc,   :root, 'imw', 'etc'   ],
    [:site,      :root, 'site'         ],
    
    [:ripd_root, :root, 'ripd'         ],   
    
    [:pool_root, :root, 'pool'         ],
    [:rawd_root, :root, 'rawd'         ],   
    [:dump_root, :root, 'dump'         ],   
    [:fixd_root, :root, 'fixd'         ],   
    [:pkgd_root, :root, 'pkgd'         ],   
    
    [:cs,        :cat,  :subcat,       ],
    [:me,        :cat,  :subcat, :pool,],
    [:csp,       :cat,  :subcat, :pool,],
          
    [:code,      :pool_root, :me,      ],
    [:rawd,      :rawd_root, :me,      ],
    [:dump,      :dump_root, :me,      ],
    [:fixd,      :fixd_root, :me,      ],
    [:pkgd,      :pkgd_root, :me,      ],
    
   ]

  #
  # Set up paths to the given pool.
  #
  def init_paths(cat, subcat, pool)
    self.paths ||= {}
    # pool-specific paths (need to set cat/subcat/pool in initialize())
    pool_paths = 
      [ [:cat, cat], [:subcat, subcat], [:pool, pool] ] +
      DIRS +
      [
      # These are the files used in the default workflow
      [:pool_config_file, "imw_config-#{pool}.yaml"     ],
      [:pool_munger_file, "imw_munger-#{pool}.rb"       ],       
      [:pool_schema_file, "imw_schema-#{pool}.icss.yaml"],    
      [:pool_config,      :code, :pool_config_file],
      [:pool_munger,      :code, :pool_munger_file],
      [:pool_schema,      :code, :pool_schema_file],
      ]
    pool_paths.each do |dir, *paths|
      self.paths[dir] = path_to(*paths)
    end
  end

  # Get the path to a certain dataset workflow object
  #
  # Pass in any sequence of strings and symbols.  Note that the short tokens
  # (:pkgd, :rawd, etc) refer to that segment's _pool-specific_ file, not its
  # root (:rawd => imw/rawd/cat/subcat/pool while :rawd_root => imw/rawd)
  #
  def path_to(*parts)
    str_parts = parts.map do |part|
      part = (part.is_a? Symbol) ? (self.paths[part]||part.to_s) : part.to_s
      part.gsub(/\/*$/,'') # correct for trailing /'s
    end
    File.join(str_parts)
  end

  # Relative path from any IMW_ROOT/part to the pool.
  def me()
    path_to(:me)
  end

  #
  # Tree structure
  #
  # Looks at the given path and, if it looks like an imw tree path,
  # identifies the component parts
  #
  # FIXME -- this is pretty crappy.
  #
  def IMWPaths.grok_path(path)
    # clean up path a tad... (I bet there's a library call for this.
    path = path.gsub(/\/\/+/,'/')
    #                    head/      seg/                       cat/    subcat/ pool/  tail
    m = path.match(%r!\A(?:(.*?)/)?(pool|rawd|dump|fixd|pkgd)/([^/]+)/([^/]+)/([^/]+)(/.*?)?$!) ||
        path.match(                                    %r!()()([^/]+)/([^/]+)/([^/]+)(/.*?)?$!)
    if (m.blank?) 
      warn("Can't identify our place in #{path} -- it needs to sit below an identifiable cat/subcat/pool directory") 
      return nil
    end
    Hash.zip([:full, :head, :seg, :cat, :subcat, :pool, :tail], m.to_a)
  end

end

# puts "#{File.basename(__FILE__)}: Your monkeywrench glows alternately dim then bright as you wander, suggesting to you which paths to take." 
