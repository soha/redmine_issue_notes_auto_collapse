Redmine::Plugin.register :issue_notes_auto_collapse do
  name 'Issue Notes Auto Collapse plugin'
  author 'sohatach'
  description 'This is a plugin for Redmine 2.5.3'
  version '0.0.1'
  url 'https://github.com/soha/IssueNotesAutoCollapsePlugin'
  author_url 'https://github.com/soha'
end

Rails.configuration.to_prepare do
  unless JournalsHelper.included_modules.include?(IssueNotesAutoCollapseHelper)
    JournalsHelper.send(:include, IssueNotesAutoCollapseHelper)
  end
end

