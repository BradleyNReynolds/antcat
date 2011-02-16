require 'spec_helper'

describe Taxon do

  it "should require a name" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => 'valid'
    taxon.name.should == 'Cerapachynae'
  end

  it "should not be (Rails) valid with a blank status" do
    Taxon.new(:name => 'Cerapachynae').should_not be_valid
    Taxon.new(:status => 'valid').should_not be_valid
    Taxon.new(:name => 'Cerapachynae', :status => '').should_not be_valid
    Taxon.new(:name => '', :status => 'valid').should_not be_valid
    Taxon.new(:name => 'Cerapachynae', :status => 'valid').should be_valid
  end

  it "when status 'valid', should not be invalid" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => 'valid'
    taxon.should_not be_invalid
  end

  it "should be able to be unidentifiable" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => 'valid'
    taxon.should_not be_unidentifiable
    taxon.update_attribute :status, 'unidentifiable'
    taxon.should be_unidentifiable
    taxon.should be_invalid
  end

  it "should be able to be unavailable" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => 'valid'
    taxon.should_not be_unavailable
    taxon.should be_available
    taxon.update_attribute :status, 'unavailable'
    taxon.should be_unavailable
    taxon.should_not be_available
    taxon.should be_invalid
  end

  it "should be able to be a synonym" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => 'valid'
    taxon.should_not be_synonym
    taxon.update_attribute :status, 'synonym'
    taxon.should be_synonym
    taxon.should be_invalid
  end

  it "should be able to be a fossil" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => 'valid'
    taxon.should_not be_fossil
    taxon.update_attribute :fossil, true
    taxon.should be_fossil
  end

  it "should raise if anyone calls #children directly" do
    lambda {Taxon.new.children}.should raise_error NotImplementedError
  end

  it "should be able to be a synonym of something else" do
    gauromyrmex = Taxon.create! :name => 'Gauromyrmex', :status => 'valid'
    acalama = Taxon.create! :name => 'Acalama', :status => 'synonym', :synonym_of => gauromyrmex
    acalama.reload
    acalama.should be_synonym
    acalama.reload.synonym_of.should == gauromyrmex
  end

  it "should be able to be a homonym of something else" do
    neivamyrmex = Taxon.create! :name => 'Neivamyrmex', :status => 'valid'
    acamatus = Taxon.create! :name => 'Acamatus', :status => 'homonym', :homonym_of => neivamyrmex
    acamatus.reload
    acamatus.should be_homonym
    acamatus.homonym_of.should == neivamyrmex
  end

end
