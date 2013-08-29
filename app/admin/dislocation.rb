# -*- coding: utf-8 -*-
ActiveAdmin.register Dislocation do
  decorate_with UserDecorator

  actions :all, :except => [:new]
  menu :if => proc{ can? :view_dislocation, User }, :priority => 20

  #scope :with_current_roles, :default => true

  index do
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
    column :current_role_uic, -> (user) { Uic.find_by(:id => user.current_role_uic_id).try(:number) || user.current_role_uic_id }
    column :current_role_id, -> (user) { CurrentRole.find_by(:id => user.current_role_id).try(:name) || user.current_role_id }
    column :current_role_nomination_source_id, -> (user) { NominationSource.find_by(:id => user.current_role_nomination_source_id).try(:name) || user.current_role_nomination_source_id }
    column :got_docs, -> (user) { I18n.t user.got_docs.to_s }
    column :dislocation_errors, -> (user) { ' TODO ' }
  end

  filter :organisation, label: 'Организация', as: :select, collection: proc { Organisation.order(:name) }, :input_html => {:style => "width: 230px;"}
  filter :adm_region, :as => :select, :collection => proc { Region.adm_regions }, :input_html => {:style => "width: 230px;"}
  filter :region, :as => :select, :collection => proc { Region.mun_regions }, :input_html => {:style => "width: 230px;"}
  filter :user_app_last_name, as: :string, label: 'Фамилия'
  filter :phone
  filter :got_docs
  filter :current_role_uic, as: :numeric
  filter :current_role_nomination_source_id, as: :select, collection: proc { NominationSource.order(:name) }, :input_html => {:style => "width: 230px;"}
  # filter :dislocation_errors, as: :something

  controller do
    def scoped_collection
      Dislocation.with_current_roles.with_role :observer
    end
  end

end
