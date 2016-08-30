require 'date'
require 'json'
require 'rainbow/ext/string'

command :logs do |c|
  c.syntax = %{mr logs [options]}
  c.description = %{Get the logs for a solution}
  c.option '-f','--follow', %{Follow logs from server}
  c.option '--pollrate RATE', Integer, %{Seconds to sleep between polls}
  c.option('--[no-]color', %{Toggle colorizing of logs}) {
    Rainbow.enabled = false
  }
  c.option '--[no-]pretty', %{Reformat JSON blobs in logs.}
  c.option '--[no-]localtime', %{Adjust Timestamps to be in local time}

  c.action do |args,options|
    options.default :pretty=>true, :localtime=>true, :pollrate=>5

    lasttime = ""

    sol = MrMurano::Solution.new
    begin
      ret = sol.get('/logs') # TODO: ('/logs?polling=true') Currently ignored.

      if ret.kind_of?(Hash) and ret.has_key?('items') then
        ret['items'].reverse.each do |line|
          curtime = ""

          line.sub!(/^\[[^\]]*\]/) {|m| m.color(:red).background(:aliceblue)}
          line.sub!(/\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d+)(?:\+\d\d:\d\d)/) {|m|
            if options.localtime then
              m = DateTime.parse(m).to_time.localtime.to_datetime.iso8601(3)
            end
            curtime = m
            m.color(:blue)
          }

          line.gsub!(/\{(?>[^}{]+|\g<0>)*\}/m) do |m|
            if options.pretty then
              js = JSON.parse(m, {:allow_nan=>true, :create_additions=>false})
              ret = JSON.pretty_generate(js).to_s
              ret[0] = ret[0].color(:magenta)
              ret[-1] = ret[-1].color(:magenta)
              ret
            else
              m.sub!(/^{/){|ml| ml.color(:magenta)}
              m.sub!(/}$/){|ml| ml.color(:magenta)}
              m
            end
          end

          if curtime > lasttime then
            lasttime = curtime
            puts line
          end
        end
      else
        say_error "Couldn't get logs: #{ret}"
        break
      end

      sleep(options.pollrate) if options.follow
    end while options.follow

  end
end
#  vim: set ai et sw=2 ts=2 :