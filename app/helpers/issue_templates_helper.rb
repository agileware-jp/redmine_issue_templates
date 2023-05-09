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

  def localize_to_script
    return {
      button_add: l(:button_add),
      button_apply: l(:button_apply),
      button_reset: l(:button_reset),
      enter_value: l(:enter_value, default: "Please enter a value"),
      field_value: l(:field_value),
      help_for_this_field: l(:help_for_this_field),
      label_field_information: l(:label_field_information, default: "Field information"),
      label_builtin_fields_json: l(:label_builtin_fields_json, default: "JSON for fields"),
      label_select_field: l(:label_select_field, default: "Select a field"),
      unavailable_fields_for_this_tracker: l(:unavailable_fields_for_this_tracker, default: "Unavailable field for this tracker"),
    }
  end
end
