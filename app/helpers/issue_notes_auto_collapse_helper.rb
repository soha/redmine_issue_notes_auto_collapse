# encoding: utf-8
#
# CustomHelper
# copy from JournalsHelper

module IssueNotesAutoCollapseHelper


  INAC_QUOTES_RE = /(^>+([^\n]*?)(\n|$))+/m
  INAC_QUOTES_CONTENT_RE = /^([> ]+)(.*)$/m
  
  def deco_block_textile_quotes( text )
    text.gsub!( INAC_QUOTES_RE ) do |match|
      lines = match.split( /\n/ )
      quotes = ''
      indent = 0
      collapse = false

      lines.each do |line|
        line =~ INAC_QUOTES_CONTENT_RE 
        bq,content = $1, $2
        l = bq.count('>')

        if l > 0 and not collapse then
          quotes << ("\n\n" + '{{collapse' + "\n\n")
          collapse = true
        end

        if l != indent then
          quotes << ("\n\n" + (l>indent ? '>' * (l-indent) : '' * (indent-l) + "\n\n"))
        end
        quotes << (content + "\n")
      end

      quotes << ("\n" + '' * indent + "\n\n")

      if collapse then
        quotes << ("\n" + '}}' "\n\n")
      end

      quotes
    end
  end


  # from application_helper.rb
  #
  # Formats text according to system settings.
  # 2 ways to call this method:
  # * with a String: textilizable(text, options)
  # * with an object and one of its attribute: textilizable(issue, :description, options)
  def deco_textilizable(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    case args.size
    when 1
      obj = options[:object]
      text = args.shift
    when 2
      obj = args.shift
      attr = args.shift
      text = obj.send(attr).to_s
    else
      raise ArgumentError, 'invalid arguments to textilizable'
    end
    return '' if text.blank?
    project = options[:project] || @project || (obj && obj.respond_to?(:project) ? obj.project : nil)
    only_path = options.delete(:only_path) == false ? false : true

    text = text.dup

    ####add custom
    text = deco_block_textile_quotes(text)
    ####

    macros = catch_macros(text)
    text = Redmine::WikiFormatting.to_html(Setting.text_formatting, text, :object => obj, :attribute => attr)

    @parsed_headings = []
    @heading_anchors = {}
    @current_section = 0 if options[:edit_section_links]

    parse_sections(text, project, obj, attr, only_path, options)
    text = parse_non_pre_blocks(text, obj, macros) do |text|
      [:parse_inline_attachments, :parse_wiki_links, :parse_redmine_links].each do |method_name|
        send method_name, text, project, obj, attr, only_path, options
      end
    end
    parse_headings(text, project, obj, attr, only_path, options)

    if @parsed_headings.any?
      replace_toc(text, @parsed_headings)
    end

    text.html_safe
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

    ####mod custom
    content << deco_textilizable(journal, :notes)
    ####

    css_classes = "wiki"
    css_classes << " editable" if editable
    content_tag('div', content.html_safe, :id => "journal-#{journal.id}-notes", :class => css_classes)
  end

end
