require 'imw/utils'
require 'imw/dataset/workflow'
require 'imw/dataset/paths'

module IMW

  # The IMW::Dataset class is useful organizing a complex data
  # transformation because it is capable of managing a collection of
  # paths and the interdependencies between subparts of the
  # transformation.
  #
  # == Manipulating Paths
  #
  # Storing paths makes code shorter and more readable.  By default
  # (this assumes the executing script is in a file
  # /home/imw_user/data/foo.rb):
  #
  #   dataset = IMW::Dataset.new
  #   dataset.path_to(:self)
  #   #=> '/home/imw_user/data'
  #   dataset.path_to(:ripd)
  #   #=> '/home/imw_user/data/ripd'
  #   dataset.path_to(:pkgd, 'final.tar.gz')
  #   #=> '/home/imw_user/data/pkgd/final.tar.gz'
  #
  # Paths can be added
  #
  #   dataset.add_path(:sorted_output, :mungd, 'sorted-file-3923.txt')
  #   dataset.path_to(:sorted_output)
  #   #=> '/home/imw_user/data/mungd/sorted-file-3923.txt'
  #
  # as well as removed (via +remove_path+).
  #
  # == Defining Workflows
  #
  # IMW encourages you to think of transforming data as a network of
  # interdependent steps (see IMW::Workflow).  Each of IMW's five
  # default steps maps to a named directory remembered by each
  # dataset.
  #
  # The following example shows why this is a useful abstraction as
  # well as illustrating some of the other functionality in IMW.
  #
  # == Example Dataset
  #
  # The first step is to import IMW and create the dataset
  #
  #   require 'rubygems'
  #   require 'imw'
  #   dataset = IMW::Dataset.new
  #
  # You can pass in a handle (the name or "slug" for the dataset) as
  # well as some options.  Now define the steps you intend to take to
  # complete the transformation:
  #
  # rip::
  #   Data is collected from a source (+http+, +ftp+, database, &c.)
  #   and deposited in the <tt>:ripd</tt> directory of this dataset.
  #
  #     dataset.task :rip do
  #       IMW.open('http://econ.chimpu.edu/datasets/produce_prices.tar.bz2').cp_to_dir(dataset.path_to(:ripd))
  #         #=> [ripd]/http/econ_chimpu_edu/datasets/produce_prices.tar.bz2
  #         
  #       IMW::Rip.from_database :named  => "weather_records",
  #                              :at     => "public.astro.chimpu.edu",
  #                              :select => "* FROM hurricane_frequency"
  #         #=> [ripd]/sql/_edu/chimpu_astro_public/weather_records/select_from_hurricane_frequency-2009-02-16--15:30:26.tsv
  #     end
  #
  #   Where <tt>[ripd]</tt> would be replaced by the IMW
  #   <tt>:ripd</tt> directory.  The default <tt>:rip</tt> task is
  #   empty so If there's no need to rip data (perhaps it's already on
  #   disk?) then nothing needs to be done here.
  #   
  # raw::
  #   Managed by the <tt>:raw</tt> task, data is uncompressed and
  #   extracted (if necessary) and stored in a subdirectory of the
  #   <tt>:data</tt> directory named by the taxon and handle of this
  #   dataset.
  #
  #     dataset.task :raw do
  #       IMW::Raw.uncompress_and_extract File.join(dataset.path_to(:ripd),'http/_edu/chimpu_econ/datasets'),
  #                                       Dir[File.join(dataset.path_to(:ripd),'sql/_edu/chimpu_astro_public/**/*.tsv')].first
  #       #=> [data]/economics/alarming_trends/recent_history_of_banana_prices/rawd/001.xml
  #           [data]/economics/alarming_trends/recent_history_of_banana_prices/rawd/002.xml
  #           [data]/economics/alarming_trends/recent_history_of_banana_prices/rawd/003.xml
  #           ...
  #           [data]/economics/alarming_trends/recent_history_of_banana_prices/rawd/select_from_hurricane_frequency-2009-02-16--15:30:26.tsv
  #     end
  #
  #   Where <tt>[data]</tt> would be replaced by the IMW
  #   <tt>:data</tt> directory.
  #
  #   If this dataset didn't have a taxon
  #   (economics/alarming_trends) its files would be stored in a
  #   directory +recent_history_of_banana_prices+ just below the
  #   <tt>:data</tt> directory.
  #
  # fix::
  #   Managed by the <tt>:fix</tt> task, transformations on the data
  #   are performed.  IMW's method is to read data from a source
  #   format (XML, YAML, CSV, &c.) into Ruby objects with hash
  #   semantics.  These objects might be based upon structs,
  #   ActiveRecord, DataMapper::Resource, FasterCSV...anything which
  #   can be accessed as <tt>thing.property</tt> (FIXME 'and' or 'or'
  #   ) <tt>thing[:property]</tt>: the Infinite Monkeywrench fits
  #   neatly into your toobox.
  #
  #
  #     # Open an output file in XML for writing
  #     output = IMW.open! File.join(dataset.path_to(:fixd), 'date_bananas_hurricanes.csv')
  #       #=> FasterCSV at [fixd]/economics/alarming_trends/recent_history_of_banana_prices/fixd/data_bananas_hurricanes.csv
  #
  #     # A place to store the combined data
  #     correlations = []
  #
  #     dataset.task :fix do
  #
  #       # Return the contents of the weather data which has rows like
  #       # 
  #       #   1    2008-09-01    4
  #       #   2    2008-09-08    3
  #       #   3    2008-08-15    3
  #       #   ...  
  #       # 
  #       weather_data = IMW.open(Dir[File.join(dataset.path_to(:rawd), '*.tsv')].first,
  #                               :headers => ["ID","DATE","NUM_HURRICANES"]).entries
  #         #=> [#<FasterCSV::Row "ID":nil "DATE":Mon Sep 08 04:15:47 -0600 2008,"NUM_HURRICANES":4>, ... ]
  #
  #
  #       # Return the matching data from the produce prices XML file which looks like
  #       # 
  #       #  <prices>
  #       #    <price type="apple">
  #       #      <date>2008/09/01</date>
  #       #      <amount>0.15</amount>
  #       #    </price>
  #       #    <price type="banana">
  #       #      <date>2008/09/01</date>
  #       #      <amount>0.20</amount>
  #       #    </price>
  #       #    ...
  #       #  </prices>
  #       parser = IMW::XMLParser.new :records => [ 'prices/price[@type="banana"]',
  #                                                 { :week  => 'date',
  #                                                   :price => 'amount' }]
  #
  #       # Loop through the XML produce prices, mixing in the hurricane data,
  #       # and outputting new rows.
  #       Dir["#{dataset.path_to :rawd}*.xml"] each do |file|
  #         IMW.open file do |xml| #=> Hpricot::Doc
  #           parser.parse(xml).each do |record|
  #             num_hurricanes = weather_data.(lambda { nil }) {|id,week,num_hurricanes| week == record.week}
  #             output << [week,record[:price],num_hurricanes]
  #           end
  #         end
  #       end
  #     end
  #
  # package::
  #   Data is packaged and compressed (if necessary) into a delivery
  #   format and deposited into the <tt>:pkgd</tt> directory.
  #
  #   dataset.task :pkg do
  #     IMW.open(File.join(dataset.path_to(:fixd), 'date_bananas_hurricanes.csv')).compress!
  #       #=> [data]/economics/alarming_trends/recent_history_of_banana_prices/pkgd/date_bananas_hurricanes.csv.bz2
  #   end
  #
  # In the above, <tt>dataset.task</tt> behaves like
  # <tt>Rake.task</tt>, merely defining a task and its dependencies
  # without executing it via
  #
  #   dataset.task(:pkg).invoke
  #
  # Since the <tt>:rip</tt>, <tt>:raw</tt>, <tt>:fix</tt>, and
  # <tt>:pkg</tt> tasks depend upon each other, invoking <tt>:pkg</tt>
  # will first cause <tt>:rip</tt> to run.
  #
  # By default, the tasks associated with a dataset are blank.  All of
  # IMW's functionality is available without defining tasks.  Tasks
  # simply provide a convenient scaffold for building a data
  # transformation upon.
  #
  # Similarly, there is no requirement to use the directory structure
  # outlined above.  IMW's methods accept plain filenames and do the
  # Right Thing where possible.  The combination of tasks with
  # matching directory structure is a suggested but not mandatory
  # framework in which to program.
  class Dataset

    # The <tt>IMW::Workflow</tt> module contains pre-defined tasks for
    # dataset processing.
    include IMW::Workflow

    attr_accessor :handle, :options, :data

    def initialize options = {}
      @options = options
      @handle  = options[:handle]
      initialize_workflow
      set_root_paths
      set_paths
      set_tasks
    end

  end
end
