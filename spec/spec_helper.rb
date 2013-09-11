ENV['RACK_ENV']                              = 'test'
ENV['CHECK_CF_CONTEST_HATENA_USER_ID']       = "user"
ENV['CHECK_CF_CONTEST_HATENA_USER_PASSWORD'] = "password"
ENV['CHECK_CF_CONTEST_HATENA_GROUP_ID']      = "group"
ENV['CHECK_CF_CONTEST_SECRET_URL']           = "test"
ENV['CHECK_CF_CONTEST_SECRET_TOKEN']         = "test"

require 'rack/test'

require 'webmock/rspec'
# WebMock.allow_net_connect!
