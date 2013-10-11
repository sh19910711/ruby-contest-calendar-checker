require 'spec_helper'

module Server
  module Contest
    describe 'T006: Timus Online Judge' do
      describe '001: Get Contest List' do
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

        it '001: Normal' do
          ret = Toj::get_contest_list()
          ret.length.should eq 3
          ret[0]["title"].should eq "Open Ural FU Championship 2013"
          ret[1]["title"].should eq "NEERC 2013, Eastern subregional contest"
          ret[2]["title"].should eq "Ural Regional School Programming Contest 2013"
        end
      end
    end
  end
end
