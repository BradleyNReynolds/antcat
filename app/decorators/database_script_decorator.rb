class DatabaseScriptDecorator < Draper::Decorator
  GITHUB_MASTER_URL = "https://github.com/calacademy-research/antcat/blob/master"

  delegate :tags, :filename_without_extension

  # Decorate class because we want to be able to call this without a script.
  def self.format_tags tags
    tags.map do |tag|
      helpers.content_tag :span, class: tag_css_class(tag) do
        helpers.raw tag.html_safe
      end
    end.join(" ").html_safe
  end

  def format_tags
    self.class.format_tags tags
  end

  def github_url
    scripts_path = DatabaseScript::SCRIPTS_DIR
    "#{GITHUB_MASTER_URL}/#{scripts_path}/#{filename_without_extension}.rb"
  end

  def empty_status
    return '??' unless database_script.respond_to?(:results)
    return 'Excluded (slow/list)' if database_script.tags.include?('list') || database_script.slow?

    if database_script.results.any?
      'Not empty'
    else
      'Empty'
    end
  end

  private

    def self.tag_css_class tag
      case tag
      when DatabaseScript::SLOW_TAG          then "warning-label"
      when DatabaseScript::VERY_SLOW_TAG     then "warning-label"
      when DatabaseScript::SLOW_RENDER_TAG   then "warning-label"
      when DatabaseScript::NEW_TAG           then "label"
      when DatabaseScript::UPDATED           then "label"
      when DatabaseScript::CSV_TAG           then "pretty-label"
      when DatabaseScript::HIGH_PRIORITY_TAG then "secondary-label"
      else                                        "white-label"
      end << " rounded-badge"
    end
    private_class_method :tag_css_class
end
