# Use `rails generate database_script <name_of_script>` to generate new scripts.

class DatabaseScript
  include Draper::Decoratable
  include DatabaseScripts::EndData
  include DatabaseScripts::Rendering

  SCRIPTS_DIR = "app/database_scripts/database_scripts"
  TAGS = [
    SLOW_TAG = "slow",
    VERY_SLOW_TAG = "very-slow",
    NEW_TAG = "new!",
    CSV_TAG = "csv",
    REGRESSION_TEST_TAG = "regression-test",
    LIST_TAG = "list",
    VALIDATED_TAG = "validated"
  ]

  ScriptNotFound = Class.new StandardError

  def self.new_from_filename_without_extension basename
    script_class = "DatabaseScripts::#{basename.camelize}".safe_constantize
    raise ScriptNotFound unless script_class

    script_class.new
  end

  def self.all
    @all ||= Dir.glob("#{SCRIPTS_DIR}/*").sort.map do |path|
               basename = File.basename path, ".rb"
               new_from_filename_without_extension basename
             end
  end

  def self.taxon_in_results? taxon
    new.results.where(id: taxon.id).exists?
  end

  def soft_validated?
    self.class.in?(Taxa::CallbacksAndValidations::DATABASE_SCRIPTS_TO_CHECK)
  end

  def description
    end_data[:description] || ""
  end

  def issue_description
    end_data[:issue_description]
  end

  def tags
    end_data[:tags] || []
  end

  def topic_areas
    end_data[:topic_areas] || []
  end

  def title
    filename_without_extension.humanize
  end

  def filename_without_extension
    @filename_without_extension ||= self.class.name.demodulize.underscore
  end

  # For `link_to "database_script", database_script_path(@database_script)`.
  def to_param
    filename_without_extension
  end

  protected

    def cached_results
      return @_results if defined? @_results

      @_results = if respond_to? :results
                    results
                  end
    end

  private

    def script_path
      "#{SCRIPTS_DIR}/#{filename_without_extension}.rb"
    end
end