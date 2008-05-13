#
# h2. imw/tasks/db/schema -- desc lib
#
# action::    desc action     
#
# == About
#
# Author::    Philip flip Kromer for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 
require 'active_record'

class Tinyfucker         < ActiveRecord::Base
end

class Pool               < ActiveRecord::Base
  # uniqname
  # name
  # created_at
  # updated_at
  # cached_tag_list
  #
  
  # ------------ Relations ----------
  has_many      :datasets
  has_many      :fields,        :through    => :pool_fields
  has_many      :contributors,  :through    => :pool_contributors
  has_many      :pool_notes # ,           :class_name => :pool_notes
  serialize     :formats
end

class Dataset             < ActiveRecord::Base
  # ------------ Relations ----------
  belongs_to    :pool
  has_many      :fields #,        :through => :dataset_fields
  has_many      :contributors #,  :through => :dataset_contributors
  has_many      :dataset_notes
  serialize     :fileinfo
end

class Contributor         < ActiveRecord::Base
  # ------------ Relations ----------
  has_many      :pools,         :through =>    :pool_contributors
  has_many      :datasets,      :through => :dataset_contributors
end

class Field               < ActiveRecord::Base
  # ------------ Relations ----------
  has_many      :pools,         :through =>   :pool_fields
  has_many      :datasets,      :through => :dataset_fields
end

class DatasetContributor  < ActiveRecord::Base
end
class PoolContributor     < ActiveRecord::Base
end
class DatasetField        < ActiveRecord::Base
end
class PoolField           < ActiveRecord::Base
end

class DatasetNote         < ActiveRecord::Base
  # ------------ Relations ----------
  belongs_to    :dataset  
end

class PoolNote            < ActiveRecord::Base
  # created_at
  # updated_at
  # 
  # pool_id
  # label   
  # note    
  
  # ------------ Relations ----------
  belongs_to    :pool  
end
