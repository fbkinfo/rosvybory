# -*- coding: utf-8 -*-
ActiveAdmin.register Dislocation do
  decorate_with DislocationDecorator

  actions :all, :except => [:new]
  menu :if => proc{ can? :view_dislocation, User }, :priority => 20

  #scope :with_current_roles, :default => true

  index do
    inplace_helper = proc do |dislocation, field, collection|
      field_value_id = dislocation.send("user_current_role_#{field}_id")
      text = field.to_s.classify.constantize.find_by(:id => field_value_id).try(:name) || field_value_id
      data = {
                pk: dislocation.pk,
                name: "#{field}_id",
                value: field_value_id,
                type: 'select',
                source: collection.map {|record| {:value => record.id, :text => record.try(:name)}},
                url: inplace_control_dislocation_path(dislocation.user_current_role_id)
              }
      content_tag(:span, text, :class => 'inplace', :data => data)
    end

    selectable_column
    actions(defaults: false) do |resource|
      link_to(I18n.t('active_admin.edit'), dislocate_user_path(resource), class: "member_link edit_link")
    end
    column "НО + id" do |dislocation|
      link_to dislocation.organisation_with_user_id, control_user_path(dislocation.user_id), :target => '_blank'
    end
    column :full_name
    column :phone
    column :adm_region, &:coalesced_adm_region_name
    column :region, &:coalesced_mun_region_name
    column :current_role_id do |dislocation|
      inplace_helper[dislocation, :current_role, CurrentRole.all]
    end
    column :current_role_uic, sortable: "user_current_roles.uic_id" do |dislocation|
      inplace_helper[dislocation, :uic, dislocation.user_current_role.selectable_uics]
    end
    column :current_role_nomination_source_id do |dislocation|
      inplace_helper[dislocation, :nomination_source, NominationSource.all]
    end
    column :user_current_role_got_docs do |dislocation|
      content_tag(:span, I18n.t(dislocation.user_current_role.got_docs?.to_s), :class => 'inplace', :data => {
          pk: dislocation.pk,
          name: 'got_docs',
          type: :select,
          source: [{value: 0, text: I18n.t('false')}, {text: I18n.t('true'), value: 1}],
          url: inplace_control_dislocation_path(dislocation.user_current_role_id),
          # trick to reduce number of clicks: invert value
          value: dislocation.user_current_role.got_docs?? 0 : 1,
          savenochange: true
        })
    end
    column "Ошибки расстановки", class: 'dislocation_errors_column' do |dislocation|
      render partial: 'cell_dislocation_errors', locals: { dislocation: dislocation }
    end
  end

  filter :organisation, label: 'Организация', as: :select, collection: proc { Organisation.order(:name) }, :input_html => {:style => "width: 230px;"}
  filter :current_role_adm_region, :as => :select, :collection => proc { Region.adm_regions }, :input_html => {:style => "width: 230px;"}
  filter :current_role_region, :as => :select, :collection => proc { Region.mun_regions }, :input_html => {:style => "width: 230px;"}
  filter :user_app_last_name, as: :string, label: 'Фамилия'
  filter :phone
  filter :current_role_uic, as: :numeric
  filter :current_role_nomination_source_id, as: :select, collection: proc { NominationSource.order(:name) }, :input_html => {:style => "width: 230px;"}
  filter :user_current_role_got_docs, as: :select
  # filter :dislocation_errors, as: :something

  batch_action :give_out_docs do |selection|
    ids = selection.reject(&:blank?)
    UserCurrentRole.find(ids).each do |ucr|
      authorize! :view_dislocation, ucr.user
      ucr.got_docs = true
      ucr.save(:validate => false)
    end
    redirect_to collection_path, :notice => "#{ids.size} records updated!"
  end

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
    editable_fields = [:got_docs, :uic_id, :current_role_id, :nomination_source_id]
    errors_normalization = {
      :uic_number => :uic_id,
      :uic => :uic_id,
      :nomination_source => :nomination_source_id,
      :current_role => :current_role_id
    }
    ucr.update_attributes params.require(:dislocation).permit(editable_fields)
    normalized_errors = ucr.errors.keys.map {|k| errors_normalization[k] || k }
    fixable_errors = normalized_errors & editable_fields
    ucr.save(validate: false) if ucr.errors.present? && fixable_errors.blank? # save if user can't help it anyway
    results = {
      :dislocation => ucr.as_json(:only => editable_fields + [:id]),
      :url => inplace_control_dislocation_path(ucr.id),
      :errors => fixable_errors,
      :message => ucr.errors.full_messages.join(' '),
      :selectable_uics => ucr.selectable_uics.map {|record| {:value => record.id, :text => record.try(:name)}}
    }
    if fixable_errors.blank?
      dislocation = Dislocation.with_current_roles.where('users.id' => user.id, 'user_current_roles.id' => ucr.id).first.decorate
      results[:dislocation_errors] = render_to_string(partial: 'cell_dislocation_errors', locals: { dislocation: dislocation })
    end
    render :json => results
  end

  # TODO(sinopalnikov): move common code to app/admin/concerns
  action_item(only: [:index]) do
    _show_all = params[:show_all] && params[:show_all].to_sym == :true
    _label = I18n.t('views.pagination.actions.pagination_' + (_show_all ? 'on' : 'off'))
    link_to _label, control_dislocations_path(:format => nil, :show_all => (_show_all ? :false : :true))
  end

  controller do
    def scoped_collection
      Dislocation.with_current_roles.with_role :observer
    end

    def apply_pagination(chain)
      return super.per(params[:show_all] && params[:show_all].to_sym == :true ? 1000000 : nil)
    end
  end

end
