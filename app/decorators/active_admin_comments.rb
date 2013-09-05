module ActiveAdminComments
  def self.comments(object)
    entities = if object.is_a? Dislocation
                 [object.user_id, object.user_app_id, object.user_id]
               elsif object.is_a? User
                 [object.id, object.user_app.id, object.id]
               elsif object.is_a? UserApp
                 user_id = object.user.try(:id)
                 [user_id, object.id, user_id]
               else
                 [nil, nil, nil]
               end
    namespace = 'control'
    conditions = [User, UserApp, Dislocation].zip(entities).reject { |_, id| id.nil? }.map { |k, id| [k, id.to_s] }
    clause = Array.new(conditions.length) { '(resource_type = ? AND resource_id = ?)' }.join(' OR ')
    ActiveAdmin::Comment.where(clause, *conditions.flatten).where(namespace: namespace).order(:updated_at)
  end

  def self.full_name_with_comments_count(object)
    count = comments(object).count
    count > 0 ? "#{object.full_name} (#{count})" : object.full_name
  end

end