class DislocationControlDecorator < Draper::Decorator
  delegate_all

  def human_participant(index, show_contacts = false)
    role = participant(index)
    return unless role
    user = role.user
    source = role.nomination_source
    [
      user.full_name,
      role.current_role.name,
      source && [
        source.name,
        source.human_variant
      ].join(', ') || 'Не указан',
      show_contacts && [
        user.phone,
        h.link_to(user.email, "mailto:#{user.email}")
      ] || '***'  #  'контакты скрыты'
    ].flatten.join('<br/>').html_safe
  end

  def number_and_region
    [number, region.name].join(', ')
  end

end