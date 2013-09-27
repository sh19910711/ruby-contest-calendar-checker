require 'mechanize'
require 'date'
require 'sinatra/base'

CHECK_CF_CONTEST_HATENA_USER_ID       = ENV['CHECK_CF_CONTEST_HATENA_USER_ID']
CHECK_CF_CONTEST_HATENA_USER_PASSWORD = ENV['CHECK_CF_CONTEST_HATENA_USER_PASSWORD']
CHECK_CF_CONTEST_HATENA_GROUP_ID      = ENV['CHECK_CF_CONTEST_HATENA_GROUP_ID']
CHECK_CF_CONTEST_SECRET_URL           = ENV['CHECK_CF_CONTEST_SECRET_URL']
CHECK_CF_CONTEST_SECRET_TOKEN         = ENV['CHECK_CF_CONTEST_SECRET_TOKEN']

def get_contest_line contest
  date     = contest["date"]
  str_date = date.strftime("%H:%M")
  title    = contest["title"]
  tag      = contest["tag"]
  title.include?(tag) ?  "* #{str_date} #{title}" : "* #{str_date} [#{tag}] #{title}"
end

# 指定したはてなグループのカレンダーにテキストを追加する実験
# 指定した日付にテキストを追加する
def test_set_data_to_hatena_group_calendar(group_id, contest)
  date     = contest["date"]
  str_date = date.strftime("%H:%M")
  title    = contest["title"]
  tag      = contest["tag"]
  data     = "* #{str_date} #{title}"
  agent             = Mechanize.new
  agent.user_agent  = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  login_url = 'https://www.hatena.ne.jp/login'
  page      = agent.get(login_url)
  next_page = page.form_with do |form|
    form["name"]     = CHECK_CF_CONTEST_HATENA_USER_ID
    form["password"] = CHECK_CF_CONTEST_HATENA_USER_PASSWORD
  end.submit
  # 追加済みのデータがあるときは何もしない
  target_url = "https://#{group_id}.g.hatena.ne.jp/keyword/#{date.strftime("%Y-%m-%d")}?mode=edit"
  agent.get(target_url).form_with(:name => 'edit') do |form|
    next unless form
    break if form["body"].include?(title)
    form["body"] += "\n" + get_contest_line(contest) + "\n"
    form.submit
  end
end

# Codeforcesのコンテストリストを取得する
def test_get_contest_list_from_codeforces()
  agent = Mechanize.new
  agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  contest_list_url = "http://codeforces.com/contests?locale=en"
  page = agent.get(contest_list_url)
  doc = Nokogiri::HTML(page.body)
  element = doc.xpath('//div[@class="contestList"]//div[@class="datatable"]').first
  contest_list = []
  element.search('tr[@data-contestid]').each do |entry|
    elements         = entry.search('td')
    # 時差は5時間
    contest          = {}
    elements[0].search("*").remove()
    contest["title"] = elements[0].inner_text.strip
    str_date         = elements[1].inner_text.strip
    date             = DateTime.strptime("#{str_date}", "%m/%d/%Y %H:%M")
    date = date.new_offset(Rational(4, 24))
    date -= Rational(4, 24)
    if /PM$/.match(str_date)
      if ( date.hour != 12 )
        date += Rational(12, 24)
      end
    end
    date = date.new_offset(Rational(9, 24))
    contest["date"] = date
    contest["tag"] = "Codeforces"
    contest_list.push(contest)
  end
  return contest_list
end

# Codeforcesのコンテストリストを取得する
def test_get_contest_list_from_codechef()
  agent            = Mechanize.new
  agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  contest_list_url = "http://www.codechef.com/contests"
  page             = agent.get(contest_list_url)
  doc              = Nokogiri::HTML(page.body)
  table            = doc.xpath('//div[@id = "primary-content"]//table')[0]
  contest_list     = []

  table.search('tr')[1..-1].each do |tr|
    contest = {}
    elements = tr.search('td')
    id = elements[0].text.strip
    title = elements[1].search('a')[0].text.strip
    start_time = elements[2].text.strip
    date = DateTime.strptime("#{start_time} IST", "%Y-%m-%d %H:%M:%s %z")
    date = date.new_offset(Rational(9, 24))

    contest["title"] = title
    contest["date"] = date
    contest["tag"] = "CodeChef"
    contest_list.push contest
  end

  contest_list
end

# Codeforcesのコンテストリストを取得する
def test_get_contest_list_from_uva()
  agent            = Mechanize.new
  agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  contest_list_url = "http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=12"
  page             = agent.get(contest_list_url)
  doc              = Nokogiri::HTML(page.body)
  table            = doc.xpath('//div[@id="main"]/div[@id="col3"]//table')[0]
  contest_list     = []

  table.search('tr')[1..-1].each do |tr|
    elements = tr.search('td')
    id = elements[0].text.strip
    title = elements[2].text.strip
    start_time = elements[3].text.strip
    date = DateTime.strptime("#{start_time} UTC", "%Y-%m-%d %H:%M:%s %z")
    date = date.new_offset(Rational(9, 24))

    contest = {}
    contest["title"] = title
    contest["date"] = date
    contest["tag"] = "UVa"
    contest_list.push contest
  end

  contest_list
end

# 重複するコンテスト（Div.1 Div.2など）を一つにまとめる処理
def get_unique_contest_list(contest_list)
  pass_list = Hash.new
  res       = []
  len       = contest_list.length
  (0..(len-1)).each do |i|
    ok      = true
    date_i  = contest_list[i]["date"]
    title_i = contest_list[i]["title"]
    if /(.*)\(Div.\s?[12]\)/.match(title_i) && pass_list.key?(/(.*)\(Div.\s?[12]\)/.match(title_i)[1].strip)
      next
    end
    ((i+1)..(len-1)).each do |j|
      date_j  = contest_list[j]["date"]
      title_j = contest_list[j]["title"]
      if ( date_i == date_j )
        regexp = /\(Div.\s?[12]\)/
        if ( regexp.match(title_i) && regexp.match(title_j) )
          contest_title = /(.*)\(Div.\s?[12]\)/.match(title_i)[1].strip
          res.push({
            "title" => contest_title,
            "date"  => contest_list[i]["date"],
            "tag"   => contest_list[i]["tag"]
          })
          pass_list[contest_title] = true
          ok = false
        end
      end
    end
    res.push contest_list[i] if ok
  end
  res
end

def find_new_contest_from_codeforces()
  contest_list = test_get_contest_list_from_codeforces
  contest_list = get_unique_contest_list(contest_list)
  contest_list.each do |contest|
    test_set_data_to_hatena_group_calendar(CHECK_CF_CONTEST_HATENA_GROUP_ID, contest)
  end
end

def find_new_contest_from_codechef()
  contest_list = test_get_contest_list_from_codechef
  contest_list = get_unique_contest_list(contest_list)
  contest_list.each do |contest|
    test_set_data_to_hatena_group_calendar(CHECK_CF_CONTEST_HATENA_GROUP_ID, contest)
  end
end

def find_new_contest_from_uva()
  contest_list = test_get_contest_list_from_uva
  contest_list = get_unique_contest_list(contest_list)
  contest_list.each do |contest|
    test_set_data_to_hatena_group_calendar(CHECK_CF_CONTEST_HATENA_GROUP_ID, contest)
  end
end

class App < Sinatra::Base
  post "/#{CHECK_CF_CONTEST_SECRET_URL}" do
    halt 403 if CHECK_CF_CONTEST_SECRET_TOKEN != params[:token]
    find_new_contest_from_codeforces()
    find_new_contest_from_codechef()
    find_new_contest_from_uva()
    'OK'
  end

  configure :development do
    puts "### DEVELOPMENT_MODE ###"
    get "/check" do
      halt 403 unless ENV['DEVELOPMENT_MODE'] === 'TRUE'
      find_new_contest_from_codeforces()
      find_new_contest_from_codechef()
      find_new_contest_from_uva()
      'OK'
    end
  end
end

