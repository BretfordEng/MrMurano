require 'netrc'
require 'uri'
require 'net/http'
require 'json'
require 'date'
require 'pp'
require 'terminal-table'

module MrMurano
  class Account


    def endPoint(path)
      URI('https://' + $cfg['net.host'] + '/api:1/' + path.to_s)
    end

    def _password
      host = $cfg['net.host']
      user = $cfg['user.name']
      if user.nil? then
        user = ask("Account name: ")
        $cfg['user.name'] = user
      end
      # Maybe in the future use Keychain.  For now all in Netrc.
#      if (/darwin/ =~ RUBY_PLATFORM) != nil then
#        # macOS
#        pws = `security 2>&1 >/dev/null find-internet-password -gs "#{host}" -a "#{user}"`
#        pws.strip!
#        pws.sub!(/^password: "(.*)"$/, '\1')
#        return pws
      # Use Netrc
      nrc = Netrc.read
      ruser, pws = nrc[host]
      pws = nil unless ruser == user
      if pws.nil? then
        pws = ask("Password:  ") { |q| q.echo = "*" }
        nrc[host] = user, pws
        nrc.save
      end
      pws
    end

    def token
      if @token.nil? then
        r = endPoint('token/')
        Net::HTTP.start(r.host, r.port, :use_ssl=>true) do |http|
          request = Net::HTTP::Post.new(r)
          request.content_type = 'application/json'
          #request.basic_auth(username(), password())
          request.body = JSON.generate({
            :email => $cfg['user.name'],
            :password => _password
          })

          response = http.request(request)
          case response
          when Net::HTTPSuccess
            token = JSON.parse(response.body)
            @token = token['token']
          else
            say_error "No token! because: #{response}"
            @token = nil
            raise response
          end
        end
      end
      @token
    end

    def businesses
      r = endPoint('user/' + $cfg['user.name'] + '/membership/')
      Net::HTTP.start(r.host, r.port, :use_ssl=>true) do |http|
        request = Net::HTTP::Get.new(r)
        request.content_type = 'application/json'
        request['authorization'] = 'token ' + token

        response = http.request(request)
        case response
        when Net::HTTPSuccess
          busy = JSON.parse(response.body)
          return busy
        else
          raise response
        end
      end
    end

    def products
      r = endPoint('business/' + $cfg['business.id'] + '/product/')
      Net::HTTP.start(r.host, r.port, :use_ssl=>true) do |http|
        request = Net::HTTP::Get.new(r)
        request.content_type = 'application/json'
        request['authorization'] = 'token ' + token

        response = http.request(request)
        case response
        when Net::HTTPSuccess
          busy = JSON.parse(response.body)
          return busy
        else
          raise response
        end
      end
    end

    def solutions
      r = endPoint('business/' + $cfg['business.id'] + '/solution/')
      Net::HTTP.start(r.host, r.port, :use_ssl=>true) do |http|
        request = Net::HTTP::Get.new(r)
        request.content_type = 'application/json'
        request['authorization'] = 'token ' + token

        response = http.request(request)
        case response
        when Net::HTTPSuccess
          busy = JSON.parse(response.body)
          return busy
        else
          raise response
        end
      end
    end

  end
end

# This is largely for testing.
command :account do |c|
  c.syntax = %{mr account ...}
  c.option '--businesses', 'Get businesses for user'

  c.action do |args, options|

    acc = MrMurano::Account.new
    if options.businesses then
      busy = acc.businesses.map{|row| [row['bizid'], row['role'], row['name']]}
      
      table = Terminal::Table.new :rows => busy, :headings => ['bizid', 'Role', 'Name']
      say table
    else
      say acc.token
    end
  end
end
#  vim: set ai et sw=2 ts=2 :