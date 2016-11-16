# The query generated by `Taxon.find_by_name @taxon.type_name.to_s`
# in `TaxonDecorator::Headline` can cost up to 50-100 ms for taxa with type names, and
# that's when the cache already is running hot.

class AddNameCacheIndexToTaxa < ActiveRecord::Migration
  def change
    add_index :taxa, :name_cache
  end
end
