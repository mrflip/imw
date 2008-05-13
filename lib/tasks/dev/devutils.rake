namespace :dev do
  
  desc "Generate code statistics"
  task :lines do
    lines, codelines, total_lines, total_codelines = 0, 0, 0, 0

    for file_name in FileList["lib/**/*.rb"]
      next if file_name =~ /vendor/
      f = File.open(file_name)

      while line = f.gets
        lines += 1
        next if line =~ /^\s*$/
        next if line =~ /^\s*#/
          codelines += 1
      end
      puts "L: #{sprintf("%4d", lines)}, LOC #{sprintf("%4d", codelines)} | #{file_name}"
      
      total_lines     += lines
      total_codelines += codelines
      
      lines, codelines = 0, 0
    end

    puts "Total: Lines #{total_lines}, LOC #{total_codelines}"
  end

  desc "Make TAGS file for editing"
  task :tags do |t|
    sh %{ ctags -e -R --exclude=doc --exclude=pool --exclude=test --langmap='ruby:+.erb.rake' }
  end
  
end
  
