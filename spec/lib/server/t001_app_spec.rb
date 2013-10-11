# coding: utf-8

require 'spec_helper'
require 'server/app'

describe 'T001: Routing Test' do
  include Rack::Test::Methods

  # Fake Codeforces Contests
  before do
    response_body = read_file_from_mock("/mock/codeforces_com_contests_locale_en.html")
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
    response_body = read_file_from_mock("/mock/codechef_contest.html")
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
    response_body = read_file_from_mock("/mock/uva_contest.html")
    stub_request(:get, 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=12').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  # Fake Codechef Contests
  before do
    response_body = read_file_from_mock("/mock/toj_contest.html")
    stub_request(:get, 'http://acm.timus.ru/schedule.aspx').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  # ID=166
  before do
    response_body = read_file_from_mock("/mock/toj_contest_166.html")
    stub_request(:get, 'http://acm.timus.ru/contest.aspx?id=166').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  # ID=169
  before do
    response_body = read_file_from_mock("/mock/toj_contest_169.html")
    stub_request(:get, 'http://acm.timus.ru/contest.aspx?id=169').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  # ID=170
  before do
    response_body = read_file_from_mock("/mock/toj_contest_170.html")
    stub_request(:get, 'http://acm.timus.ru/contest.aspx?id=170').to_return({
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
    Server::App.new
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
