require 'imw/utils/paths'

module IMW
  class Dataset
    #
    # Guess the file format of a given file
    #
    def self.file_format filename
      File.extname(path_to(filename)).gsub(/^\./,'').to_sym
    end

    #
    # KLUDGE -- the below should sometime evolve into
    # a facade + factory.  This worksfornow.
    #

    #
    # Return a new dataset from the given file
    #
    #
    #
    def self.load filename, &block
      filename = path_to(filename)
      announce "Loading #{filename}"
      format ||= file_format(filename)
      file     = File.open(filename)
      data = case format
      when :yaml
        YAML.load file
      else
        raise "Don't know how to dump a #{format} file"
      end
      data = yield data if block
      self.new(data)
    end

    #
    # Dump the given data structure to a file,
    # guessing the format and all that stupid crap.
    #
    def self.dump data, filename, format = nil
      filename = path_to(filename)
      announce "Dumping #{filename}"
      format ||= Dataset.file_format(filename)
      file     = File.open(filename, 'w')
      case format
      when :yaml
        YAML.dump(data, file)
      else
        raise "Don't know how to dump a #{format} file"
      end
    end
    #
    # dispatch to Dataset.dump
    def dump *args
      self.class.dump self.data, *args
    end

  end
end
