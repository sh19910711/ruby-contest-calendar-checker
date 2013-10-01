# coding: utf-8

require 'spec_helper'
require 'server/app'

include Server

describe 'T001: Routing Test' do
  include Rack::Test::Methods

  # Fake Codeforces Contests
  before do
    response_body = File.read(File.dirname(__FILE__) + "/mock/codeforces_com_contests_locale_en.html")
    stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  # Fake Codechef Contests
  before do
    response_body = File.read(File.dirname(__FILE__) + "/mock/codechef_contest.html")
    stub_request(:get, 'http://www.codechef.com/contests').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  # Fake UVa Contests
  before do
    response_body = File.read(File.dirname(__FILE__) + "/mock/uva_contest.html")
    stub_request(:get, 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=12').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  # Fake Hatena Login
  before do
    stub_request(:get, 'https://www.hatena.ne.jp/login').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => '<form action="/login" method="post"></form>',
    })
    stub_request(:post, 'https://www.hatena.ne.jp/login').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => '<form action="/login" method="post"></form>',
    })
  end

  # Fake Hatena Group
  before do
    stub_request(:get, /https:\/\/group.g.hatena.ne.jp\/keyword\/.*/).to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => 'test',
    })
  end

  def app
    App.new
  end

  describe '001: POST /test' do
    before do
      post '/test', {"token" => "test"}
    end
    it '001: with valid token' do
      last_response.should be_ok
    end
  end

  describe '002: POST /test' do
    before do
      post '/test', {"token" => "test2"}
    end
    it '001: with invalid token' do
      last_response.should_not be_ok
    end
  end

  describe '003: POST /test' do
    before do
      post '/test', {"token" => "1test"}
    end
    it '001: with invalid token' do
      last_response.should_not be_ok
    end
  end

end

describe 'T002: Codeforces Parsing Test' do
  describe '001: Get contest list.1' do
    # Fake Codeforces Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/t002_001.html")
      stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it '001: Duplicate' do
      ret = test_get_contest_list_from_codeforces()
      ret.length.should == 3
    end

    it '002: Unique' do
      ret1 = test_get_contest_list_from_codeforces()
      ret1.length.should == 3
      ret2 = get_unique_contest_list(ret1)
      ret2.length.should == 2
    end
  end

  describe '002: Get contest list.2' do
    # Fake Codeforces Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/t002_002.html")
      stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it '001: Duplicate' do
      ret = test_get_contest_list_from_codeforces()
      ret.length.should == 4
    end

    it '002: Unique' do
      ret1 = test_get_contest_list_from_codeforces()
      ret1.length.should == 4
      ret2 = get_unique_contest_list(ret1)
      ret2.length.should == 3
    end
  end

  describe '003: Time Test.1' do
    # Fake Codeforces Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/t002_003.html")
      stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it '001: Check Time' do
      ret = test_get_contest_list_from_codeforces()
      ret[0]["date"].should eq DateTime.parse('2013-09-11T17:00JST')
      ret[1]["date"].should eq DateTime.parse('2013-09-11T17:00JST')
      ret[2]["date"].should eq DateTime.parse('2013-09-30T17:30JST')
      ret[3]["date"].should eq DateTime.parse('2013-09-30T17:45JST')
      ret[4]["date"].should eq DateTime.parse('2013-12-24T10:00JST')
      ret[5]["date"].should eq DateTime.parse('2013-12-25T00:00JST')
      ret[6]["date"].should eq DateTime.parse('2013-12-25T00:30JST')
    end
  end

  describe '004: Get Contest List(Running)' do
    # Fake Codeforces Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/codeforces_com_contests_running.html")
      stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it '001: Get Contest List' do
      ret = test_get_contest_list_from_codeforces()
      ret[0]["title"].should eq "Codeforces Round #200 (Div. 1)"
      no_dup = get_unique_contest_list(ret)
      no_dup[0]["title"].should eq "Codeforces Round #200"
    end
  end

end

describe 'T003: Codechef' do
  include Rack::Test::Methods

  def app
    App.new
  end

  describe '001: Get Contest List' do
    # Fake Codechef Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/codechef_contest.html")
      stub_request(:get, 'http://www.codechef.com/contests').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it '001: Get Contest List' do
      ret = test_get_contest_list_from_codechef()
      ret.length.should eq 1
      ret[0]["title"].should eq "September Cook-Off 2013"
    end
  end
end

describe 'T004: UVa' do
  include Rack::Test::Methods

  def app
    App.new
  end

  # Fake UVa Contests
  before do
    response_body = File.read(File.dirname(__FILE__) + "/mock/uva_contest.html")
    stub_request(:get, 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=12').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  describe '001: Parsing Test' do
    it '001: Get Contest List' do
      ret = test_get_contest_list_from_uva()
      ret.length.should eq 4
      ret[0]["title"].should eq "The 9th Hunan Collegiate Programming Contest Semilive"
      ret[1]["title"].should eq "Latin America Regional"
      ret[2]["title"].should eq "An european regional"
      ret[3]["title"].should eq "An asian regional"
    end
  end

  describe '002: Parsing Test' do
    # Fake UVa Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/t004_002.html")
      stub_request(:get, 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=12').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it '001: Get Contest List' do
      ret = test_get_contest_list_from_uva()
      ret.length.should eq 4
      ret[0]["title"].should eq "The 9th Hunan Collegiate Programming Contest Semilive"
      ret[1]["title"].should eq "Latin America Regional"
      ret[2]["title"].should eq "An european regional"
      ret[3]["title"].should eq "An asian regional"
    end
  end
end

describe 'T005: get_contest_line' do
  include Rack::Test::Methods
  def app
    App.new
  end

  describe '001: No tag cases' do
    it '001' do
      date = Time.new
      date_text = date.strftime('%H:%M')
      ret = get_contest_line(
        {
          "title" => "Hello",
          "tag" => "Hello",
          "date" => date
        },
      )
      ret.should === "* #{date_text} Hello"
    end
    it '002' do
      date = Time.new
      date_text = date.strftime('%H:%M')
      ret = get_contest_line(
        {
          "title" => "Fullo",
          "tag" => "Hello",
          "date" => date
        },
      )
      ret.should === "* #{date_text} [Hello] Fullo"
    end
    it '003: check upper/lower cases' do
      date = Time.new
      date_text = date.strftime('%H:%M')
      ret = get_contest_line(
        {
          "title" => "Hello",
          "tag" => "hello",
          "date" => date
        },
      )
      ret.should === "* #{date_text} [hello] Hello"
    end
    it '004' do
      date = Time.new
      date_text = date.strftime('%H:%M')
      ret = get_contest_line(
        {
          "title" => "Hello World",
          "tag" => "Hello",
          "date" => date
        },
      )
      ret.should === "* #{date_text} Hello World"
    end
    it '005' do
      date = Time.new
      date_text = date.strftime('%H:%M')
      ret = get_contest_line(
        {
          "title" => "Super Hello World",
          "tag" => "Hello",
          "date" => date
        },
      )
      ret.should === "* #{date_text} Super Hello World"
    end
  end
end

