# -*- coding: utf-8 -*-
ActiveAdmin.register Dislocation do
  decorate_with DislocationDecorator

  actions :all, :except => [:new]
  menu :if => proc{ can? :view_dislocation, User }, :priority => 20

  #scope :with_current_roles, :default => true

  index do
    inplace_helper = proc do |dislocation, field, collection, display_method|
      field_value_id = dislocation.send("user_current_role_#{field}_id")
      text = field.to_s.classify.constantize.find_by(:id => field_value_id).try(display_method) || field_value_id
      data = {
                pk: dislocation.pk,
                name: "#{field}_id",
                value: field_value_id,
                type: 'select',
                source: collection.map {|record| {:value => record.id, :text => record.try(display_method)}},
                url: inplace_control_dislocation_path(dislocation.user_current_role_id)
              }
      content_tag(:span, text, :class => 'inplace', :data => data)
    end

    actions(defaults: false) do |resource|
      link_to(I18n.t('active_admin.edit'), dislocate_user_path(resource), class: "member_link edit_link")
    end
    column "НО + id" do |user|
      link_to user.organisation_with_user_id, [:control, user], :target => '_blank'
    end
    column :adm_region
    column :region
    column :full_name
    column :phone
    column :current_role_uic, sortable: "user_current_roles.uic_id" do |dislocation|
      region_id = dislocation.user_current_role_region_id || dislocation.adm_region_id
      uics = region_id ? Uic.where(:region_id => region_id) : []
      inplace_helper[dislocation, :uic, uics, :number]
    end
    column :current_role_id do |dislocation|
      inplace_helper[dislocation, :current_role, CurrentRole.all, :name]
    end
    column :current_role_nomination_source_id do |dislocation|
      inplace_helper[dislocation, :nomination_source, NominationSource.all, :name]
    end
    column :user_current_role_got_docs do |dislocation|
      I18n.t ( dislocation.user_current_role_got_docs == true ).to_s
    end
    column "Ошибки расстановки", class: 'dislocation_errors_column' do |user|
      errors = user.check_dislocation_for_errors
      if errors
        render partial: 'cell_with_errors', locals: { user: user, errors: errors }
      else
        render partial: 'cell_no_errors'
      end
    end
  end

  filter :organisation, label: 'Организация', as: :select, collection: proc { Organisation.order(:name) }, :input_html => {:style => "width: 230px;"}
  filter :adm_region, :as => :select, :collection => proc { Region.adm_regions }, :input_html => {:style => "width: 230px;"}
  filter :region, :as => :select, :collection => proc { Region.mun_regions }, :input_html => {:style => "width: 230px;"}
  filter :user_app_last_name, as: :string, label: 'Фамилия'
  filter :phone
  filter :current_role_uic, as: :numeric
  filter :current_role_nomination_source_id, as: :select, collection: proc { NominationSource.order(:name) }, :input_html => {:style => "width: 230px;"}
  filter :user_current_role_got_docs, as: :select
  # filter :dislocation_errors, as: :something

  collection_action :inplace, :method => :post do
    # TODO bug? routed to member action
  end

  member_action :inplace, :method => :post do
    # FIXME method requires urgent refactoring
    user, ucr = if params[:id].present?
      ucr = UserCurrentRole.find(params[:id])
      [User.accessible_by(current_ability).find(ucr.user_id), ucr] # TODO check security policy
    else
      user = User.accessible_by(current_ability).find(params[:pk])
      [user, user.user_current_roles.build]
    end
    editable_fields = [:uic_id, :current_role_id, :nomination_source_id]
    errors_normalization = {
      :uic_number => :uic_id,
      :nomination_source => :nomination_source_id,
      :current_role => :current_role_id
    }
    ucr.update_attributes params.require(:dislocation).permit(editable_fields)
    normalized_errors = ucr.errors.keys.map {|k| errors_normalization[k] || k }
    fixable_errors = normalized_errors & editable_fields
    ucr.save(validate: false) if ucr.errors.present? && fixable_errors.blank? # save if user can't help it anyway
    render :json => {
      :dislocation => ucr.as_json(:only => editable_fields + [:id]),
      :url => inplace_control_dislocation_path(ucr.id),
      :errors => fixable_errors,
      :message => ucr.errors.full_messages.join(' ')
    }
  end

  controller do
    def scoped_collection
      Dislocation.with_current_roles.with_role :observer
    end
  end

end
