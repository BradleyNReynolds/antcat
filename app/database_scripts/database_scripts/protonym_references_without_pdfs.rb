# frozen_string_literal: true

module DatabaseScripts
  class ProtonymReferencesWithoutPdfs < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED
    end

    def results
      Reference.where(id: Citation.select(:reference_id)).
        left_outer_joins(:document).where(reference_documents: { id: nil }).
        order_by_author_names_and_year
    end

    def render
      as_table do |t|
        t.header 'Reference'
        t.rows do |reference|
          [
            link_to(reference.key_with_suffixed_year, reference_path(reference))
          ]
        end
      end
    end
  end
end

__END__

title: Protonym references without PDFs

section: long-running
category: PDFs

description: >
  Issues: %github387, %github324, %github371

related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithBlankPdfUrlsAndFilenames
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
