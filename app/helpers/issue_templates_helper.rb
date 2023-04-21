module IssueTemplatesHelper
  def project_tracker?(tracker, project)
    return false unless tracker.present?

    project.trackers.exists?(tracker.id)
  end

  def non_project_tracker_msg(flag)
    return '' if flag

    "<font class=\"non_project_tracker\">#{l(:unused_tracker_at_this_project)}</font>".html_safe
  end

  def template_target_trackers(project, issue_template)
    trackers = project.trackers
    trackers |= [issue_template.tracker] unless issue_template.tracker.blank?
    trackers.collect { |obj| [obj.name, obj.id] }
  end

  def options_for_template_pulldown(options)
    options.map do |option|
      text = option.try(:name).to_s
      tag_builder.content_tag_string(:option, text, option, true)
    end.join("\n").html_safe
  end

  def redmine_issue_template_javascript_include_tag(*sources)
    if ENV['REDMINE_ISSUE_TEMPLATE_VITE_SERVE_URL'].present?
      sources = sources.map { |source|
        "#{ENV['REDMINE_ISSUE_TEMPLATE_VITE_SERVE_URL']}/scripts/#{source}.js"
      }
      javascript_include_tag(*sources)
    else
      javascript_include_tag(*sources, plugin: :redmine_issue_templates, type: :module)
    end
  end
end
