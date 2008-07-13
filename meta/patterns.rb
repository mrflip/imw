
class Grabber
  def distpatch_as_case(path, kind)
    case kind
    when :ftp    then grab_with_ftp(path)
    when :http   then grab_with_http(path)
    when :gopher then grab_with_gopher(path)
    else puts "oh, hell"
    end
  end

  def distpatch_as_send(path, kind)
    dispatcher = {
      :ftp    => :grab_with_ftp,
      :http   => :grab_with_http,
      :gopher => :grab_with_gopher,
    }
    self.send(dispatcher[kind], path)
  end

  def distpatch_as_send(path, kind)
    dispatcher = {
      /https?/              => :grab_with_ftp,
      /mailto|crazyproto/   => :grab_with_http,
      /gopher/              => :grab_with_gopher,
    }
    grab_func = dispatcher.find{ |patt, func| func if patt.match(kind) }
    self.send(grab_func, path)

    # there exists something like 
    # &:foo.call() if you want
  end


  def kwargs(a, foo = 5, opts, *args)
    opts.reverse_merge!({ 
                          :option_1 => "hello",
                          :option_2 => "whatever, dude"
                        })

  end

  

  
  
end
