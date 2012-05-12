class FnordQuery::Runner

  require "optparse"

  def initialize
    @opts = {}

    tasks    = %w(query web udp tcp exec)
    backends = %w(redis fyrehose)
    shorts   = { redis: :r, fyrehose: :x }

    OptionParser.new do |opts|
      opts.on("-h", "--help") do
        print_usage
        exit!
      end
      opts.on("-v", "--version") do
        print_version
        exit!
      end
      { :task => tasks, :backend => backends }.each do |lkey, list|
        list.each do |key|
          okeys = ["--#{key} [ARG]"]
          okeys << "-#{shorts[key.to_sym]} [ARG]" if shorts[key.to_sym]
          opts.on(*(okeys << String)) do |arg|
            unless arg
              puts "error: missing argument: --#{key}"
              exit!(1)
            end
            if @opts[lkey]
              puts "error: only one of #{list.join(", ")} can be given"
              exit!(1)
            end
            @opts[lkey] = [key, arg]
          end
        end
      end
    end.parse!

    if [@opts[:task], @opts[:backend]].compact.size == 0
      print_usage
    elsif @opts[:task].nil?
      puts "error: no task given"
    elsif @opts[:backend].nil?
      puts "error: no backend specified"
    end

    #backend = @opts...


  end

private

  def print_usage
    print_version
    print_help
  end

  def print_version
    puts "fnordquery 0.0.1\n\n"
  end

  def print_help
    help = <<-EOH
    Usage: fnordquery [OPTIONS...]
    -r <address>      use redis backend
    -x <address>      use fyrehose backend

    --web <address>   start web interface
    --tcp <address>   listen on tcp for events
    --udp <address>   listen on udp for events
    --query <query>   print all matching events 
    --exec <file>     run this file
    EOH

    examples = <<-EOH
    Examples:
    fnordquery -f --emit "FILTER(_channel = 'fnord')"  
    fnordquery -r localhost:6379 --udp 0.0.0.0:2323
    fnordquery -r --web 0.0.0.0:8080
    EOH

    puts [help.lstrip, nil]
    puts [examples.lstrip, nil]
    puts "http://github.com/paulasmuth/fnordquery"
  end

end
