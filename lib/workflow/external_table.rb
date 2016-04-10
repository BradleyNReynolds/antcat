# Monkeypatch into workflow gem to use taxon_state table.

module Workflow
  module ExternalTable
    module InstanceMethods

      def load_workflow_state
        # If this throws an error in testing, it's very likely that there's no associated
        # taxon_state.
        current_review_state.review_state
      end

      def persist_workflow_state new_value
        taxon_state = current_review_state
        taxon_state.review_state = new_value
        taxon_state.save!
      end

      private
        def write_initial_state
          # If we're restoring a deleted item, this
          taxon_state = current_review_state
          taxon_state.review_state = current_state.to_s
          taxon_state.save!
        end

        def current_review_state
          loaded_taxon_state = taxon_state
          unless loaded_taxon_state
            loaded_taxon_state = TaxonState.find_by(taxon: id)
          end
          loaded_taxon_state
        end
    end

    module ClassMethods
      # class methods of your adapter go here
    end

    def self.included klass
      klass.send :include, InstanceMethods
      klass.extend ClassMethods
    end

  end
end
