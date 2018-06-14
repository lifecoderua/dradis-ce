class RecordPresenter < BasePresenter

  def avatar_with_link(size)
    h.link_to(avatar_image(size), 'javascript:void(0)')
  end

  def created_at_ago
    h.local_time_ago(@object.created_at)
  end

  def icon
    icon_css = ["#{item_type}-icon", 'fa']
    icon_css <<
      case collection_type
      when 'Evidence'
        'fa-flag'
      when 'Issue'
        'fa-bug'
      when 'Node'
        'fa-folder-o'
      when 'Note'
        'fa-file-text-o'
      else
        ''
      end
    h.content_tag :span, nil, class: icon_css.join(' ')
  end

  def render_title
    [
      linked_email,
      render_partial
    ].join(' ').html_safe
  end

  # For now we can get away with just adding 'ed' to the end of the action,
  # but this may change if we add items whose action is an irregular
  # verb.
  def verb
    if @object.action == 'destroy'
      'deleted'
    else
      @object.action.sub(/e?\z/, 'ed')
    end
  end

  private

  def self.collection(type)
    define_method(:collection) do
      @object.send(type)
    end

    define_method(:collection_type) do
      @object.send("#{type}_type")
    end
  end

  def avatar_image(size)
    if @object.user
      h.image_tag(
        image_path('profile.jpg'),
        alt: @object.user,
        class: 'gravatar',
        data: { fallback_image: image_path('logo_small.png') },
        title: @object.user,
        width: size
      )
    else
      h.image_tag 'logo_small.png', width: size, alt: 'This user has been deleted from the system'
    end
  end

  def linked_email
    if @object.user
      # h.link_to(@object.user.email, 'javascript:void(0);')
      h.content_tag :strong, @object.user
    else
      'a user who has since been deleted'
    end
  end

  def render_partial
    locals = {presenter: self}
    locals[item_type] = @object
    locals[collection_type.underscore.to_sym] = collection
    render partial_path, locals
  end

  def partial_path
    partial_paths.detect do |path|
      lookup_context.template_exists? path, nil, true
    end || raise("No partial found for #{item_type} in #{partial_paths}")
  end

  def partial_paths
    [
      "activities/#{collection_type.underscore}/#{@object.action}",
      "activities/#{collection_type.underscore}",
    ]
  end
end