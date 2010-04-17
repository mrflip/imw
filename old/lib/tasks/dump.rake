
desc "export all generatable payload formats"
task :dump => 'dump:all'

# Please prepare and munge files first
task 'dump:prereqs' => [:munge, :prep]
# Also, give us that landing place  
task 'dump:prereqs' => $imw.path_to(:pkgd)

namespace :dump do 
  #
  # dump 
  #
  task :dump => [:prereqs] do |t|
  end
  task :all => :dump
  

end
