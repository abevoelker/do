# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'data_objects/spec/typecast/date_spec'

describe 'DataObjects::Oracle with Date' do
  behaves_like 'supporting Date'

  # Oracle will cast DATE type to Time
  # behaves_like 'supporting Date autocasting'
end
