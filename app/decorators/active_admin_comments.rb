module ActiveAdminComments
  def comments
    entities = if self.is_a? Dislocation
                 [self.user_id, self.user_app_id, self.user_id]
               elsif self.is_a? User
                 [self.id, self.user_app.id, self.id]
               elsif object.is_a? UserApp
                 user_id = self.user.try(:id)
                 [user_id, self.id, user_id]
               else
                 [nil, nil, nil]
               end
    namespace = 'control' # Как отсюда достучаться до active_admin_namespace или active_admin_config так и осталось неизвестным
    conditions = [User, UserApp, Dislocation].zip(entities).reject { |_, id| id.nil? }.map { |k, id| [k, id.to_s] }
    clause = Array.new(conditions.length) { '(resource_type = ? AND resource_id = ?)' }.join(' OR ')
    ActiveAdmin::Comment.where(clause, *conditions.flatten).where(namespace: namespace).order(:updated_at)
  end

  def comment_id
    self.is_a?(Dislocation) ? self.user_id : self.id
  end

  def full_name_with_comments_count
    count = comments.count
    count > 0 ? "#{self.full_name} (#{count})" : self.full_name
  end

end