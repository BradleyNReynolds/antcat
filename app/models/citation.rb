# coding: UTF-8
class Citation < ActiveRecord::Base
  belongs_to :reference

  def self.import data
    reference = Reference.find_or_create_by_bolton_key data
    create! :reference => reference, :pages => data[:pages]
  end

end
