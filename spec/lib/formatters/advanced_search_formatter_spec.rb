# coding: UTF-8
require 'spec_helper'

class FormattersAdvancedSearchFormatterTestClass
  include Formatters::AdvancedSearchFormatter
end

describe Formatters::AdvancedSearchFormatter do
  before do
    @formatter = FormattersAdvancedSearchFormatterTestClass.new
  end

  describe "Formatting search results" do
    it "should know how to do it" do
    end
  end
end
