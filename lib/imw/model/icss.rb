require 'imw/utils'
require 'facets/hash'
IMW.add_path :icss_templates, [:imw_etc, 'icss']

class ICSSchema < Hash
  cattr_accessor :templates

  def self.new_from_template template_name=:skel
    YAML.load(File.open(path_to(:icss_templates, "#{template_name}.icss.yaml")))
  end

  def self.new_dataset_from_template template_name=:skel
    self.new_from_template(template_name)['datasets'][0]
  end

end
