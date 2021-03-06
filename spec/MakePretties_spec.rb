require 'MrMurano/version'
require 'MrMurano/makePretty'

RSpec.describe MrMurano::Pretties do
  before(:example) do
    @options = {:pretty=>true, :localtime=>false}
    def @options.method_missing(mid)
      self[mid]
    end
  end

  it "makes json pretty with color" do
    data ={:type=>"debug", :timestamp=>1476386031,
           :subject=>"websocket_websocket_info",
           :data=>"Script Error: "}
    str ="\e[35m{\e[0m\n  \"type\": \"debug\",\n  \"timestamp\": 1476386031,\n  \"subject\": \"websocket_websocket_info\",\n  \"data\": \"Script Error: \"\n\e[35m}\e[0m"
    ret = MrMurano::Pretties::makeJsonPretty(data, @options)
    expect(ret).to eq(str)
  end
  it "makes json pretty without color" do
    data ={:type=>"debug", :timestamp=>1476386031,
           :subject=>"websocket_websocket_info",
           :data=>"Script Error: "}
    str ="{\"type\":\"debug\",\"timestamp\":1476386031,\"subject\":\"websocket_websocket_info\",\"data\":\"Script Error: \"}"
    @options[:pretty] = false
    ret = MrMurano::Pretties::makeJsonPretty(data, @options)
    expect(ret).to eq(str)
  end

  it "makes it pretty." do
    data ={:type=>"debug", :timestamp=>1476386031,
           :subject=>"websocket_websocket_info",
           :data=>"Script Error: "}
    str ="\e[31m\e[48;5;231mDEBUG \e[0m\e[31m\e[48;5;231m[websocket_websocket_info]\e[0m \e[34m2016-10-13T19:13:51.000+00:00\e[0m:\nScript Error: "
    ret = MrMurano::Pretties::makePretty(data, @options)
    expect(ret).to eq(str)
  end

  it "makes it pretty; missing type" do
    data ={:timestamp=>1476386031,
           :subject=>"websocket_websocket_info",
           :data=>"Script Error: "}
    str ="\e[31m\e[48;5;231m-- \e[0m\e[31m\e[48;5;231m[websocket_websocket_info]\e[0m \e[34m2016-10-13T19:13:51.000+00:00\e[0m:\nScript Error: "
    ret = MrMurano::Pretties::makePretty(data, @options)
    expect(ret).to eq(str)
  end

  it "makes it pretty; missing timestamp" do
    data ={:type=>"debug",
           :subject=>"websocket_websocket_info",
           :data=>"Script Error: "}
    str ="\e[31m\e[48;5;231mDEBUG \e[0m\e[31m\e[48;5;231m[websocket_websocket_info]\e[0m \e[34m<no timestamp>\e[0m:\nScript Error: "
    ret = MrMurano::Pretties::makePretty(data, @options)
    expect(ret).to eq(str)
  end

  it "makes it pretty; missing subject" do
    data ={:type=>"debug", :timestamp=>1476386031,
           :data=>"Script Error: "}
    str ="\e[31m\e[48;5;231mDEBUG \e[0m\e[31m\e[48;5;231m[]\e[0m \e[34m2016-10-13T19:13:51.000+00:00\e[0m:\nScript Error: "
    ret = MrMurano::Pretties::makePretty(data, @options)
    expect(ret).to eq(str)
  end


  it "makes it pretty; missing data" do
    data ={:type=>"debug", :timestamp=>1476386031,
           :subject=>"websocket_websocket_info"}
    str ="\e[31m\e[48;5;231mDEBUG \e[0m\e[31m\e[48;5;231m[websocket_websocket_info]\e[0m \e[34m2016-10-13T19:13:51.000+00:00\e[0m:\n\e[35m{\e[0m\n\e[35m}\e[0m"
    ret = MrMurano::Pretties::makePretty(data, @options)
    expect(ret).to eq(str)
  end

  it "makes it pretty; NAN timestamp" do
    data ={:type=>"debug", :timestamp => "bob",
           :subject=>"websocket_websocket_info",
           :data=>"Script Error: "}
    str ="\e[31m\e[48;5;231mDEBUG \e[0m\e[31m\e[48;5;231m[websocket_websocket_info]\e[0m \e[34mbob\e[0m:\nScript Error: "
    ret = MrMurano::Pretties::makePretty(data, @options)
    expect(ret).to eq(str)
  end
end
#  vim: set ai et sw=2 ts=2 :
