# encoding: utf-8
#
# CustomHelper
# copy from JournalsHelper

module IssueNotesAutoCollapseHelper

  def deco_collapse(str)
    return str if str.nil?
  
    sidx = str.index("<blockquote>")
    return print str if sidx.nil?
  
    rep_str = str[0..sidx]
    rep_str += "{{collapse" 
    rep_str += str[sidx..str.length]
  
    rep_str2 = "" 
    eidx = rep_str.rindex("</blockquote>")
    return print str if eidx.nil?
  
    eidx += "</blockquote>".length
    rep_str2 = rep_str[0..eidx]
    rep_str2 += "}}" 
    rep_str2 += rep_str[eidx+"}}".length..rep_str.length]
  
    print rep_str2
  end

  def render_notes_auto_collapse(issue, journal, options={})
    content = ''
    editable = User.current.logged? && (User.current.allowed_to?(:edit_issue_notes, issue.project) || (journal.user == User.current && User.current.allowed_to?(:edit_own_issue_notes, issue.project)))
    links = []
    if !journal.notes.blank?
      links << link_to(image_tag('comment.png'),
                       {:controller => 'journals', :action => 'new', :id => issue, :journal_id => journal},
                       :remote => true,
                       :method => 'post',
                       :title => l(:button_quote)) if options[:reply_links]
      links << link_to_in_place_notes_editor(image_tag('edit.png'), "journal-#{journal.id}-notes",
                                             { :controller => 'journals', :action => 'edit', :id => journal, :format => 'js' },
                                                :title => l(:button_edit)) if editable
    end
    content << content_tag('div', links.join(' ').html_safe, :class => 'contextual') unless links.empty?
    content << textilizable(journal, :notes)
    css_classes = "wiki"
    css_classes << " editable" if editable
    content_tag('div', deco_collapse(content.html_safe), :id => "journal-#{journal.id}-notes", :class => css_classes)
  end

end
