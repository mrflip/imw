require 'imw/utils'
require 'imw/dataset/workflow'
require 'imw/dataset/paths'

module IMW

  # The basic unit in IMW is the dataset.  Each dataset has a handle
  # which is meant to be unique (at least in the context of a
  # particular pool of datasets, see <tt>IMW::Pool</tt>).  A dataset
  # can also have a taxonomic classification or _taxon_
  #
  #   dataset = IMW::Dataset.new :recent_history_of_banana_prices,
  #                              :taxon => [:economics,:alarming_trends]
  #
  # but it isn't required like the handle.
  #
  # Processing a dataset commonly occurs in four course steps.  IMW
  # defines a task[http://rake.rubyforge.org] for each of these steps
  # and keeps files involved in different steps in different
  # directories.
  #
  # rip::
  #   Managed by the <tt>:rip</tt> task, data is collected from a
  #   source (+http+, +ftp+, database, &c.) and deposited in a
  #   subdirectory of the <tt>:ripd</tt> directory named for the URI
  #   of the source.
  #
  #     dataset.task :rip do
  #       IMW::Rip.from_web 'http://econ.chimpu.edu/datasets/produce_prices.tar.bz2'
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

    attr_accessor :options, :data
    attr_reader   :handle

    def initialize handle, options = {}
      self.handle= handle
      initialize_workflow
      set_paths
    end

    def handle= thing
      @handle = thing.is_a?(String) ? thing.to_handle : thing
    end

  end
end
