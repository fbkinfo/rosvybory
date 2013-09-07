class ArBredElegate
  delegate  :active_admin_config, :params,
            :table, :thead, :tbody, :tr, :th, :td,
            :link_to, :span, :br, :text_node,
            :render, :insert_tag,
            :to => :@base

  def initialize(base)
    @base = base
  end
end

class AaCachedTable < ArBredElegate

  def build(page_presenter, collection)
    table_options = {
      :id => "index_table_#{active_admin_config.resource_name.plural}",
      :sortable => true,
      :class => "index_table index",
      :i18n => active_admin_config.resource_class,
      :paginator => page_presenter[:paginator] != false
    }
    table table_options do
      thead do
        tr do
          HeaderBuilder.new(@base).instance_exec &page_presenter.block
        end
      end
      tbody do
        collection.each do |record|
          html = Rails.cache.fetch [:aa_index, record] do
            Arbre::Context.new do
              ctx = self
              tr :id => ActionController::Base.helpers.dom_id(record) do
                BodyBuilder.new(ctx, record).instance_exec &page_presenter.block
              end
            end
          end
          # text_node html.to_s.html_safe
          text_node '1'
        end
      end
    end
  end

  class HeaderBuilder < ArBredElegate
    def column(name, options = {}, &block)
      classes = Arbre::HTML::ClassList.new
      sort_key = options[:sortable]
      sort_key = name if sort_key.is_a?(TrueClass)

      classes << 'sortable'                   if sort_key
      classes << "sorted-#{current_sort[1]}"  if sort_key && current_sort[0] == sort_key
      classes << name if name.is_a? Symbol

      title = name.is_a?(String)? name : active_admin_config.resource_class.human_attribute_name(name)

      if sort_key
        th :class => classes do
          link_to(title, params.merge(:order => "#{sort_key}_#{order_for_sort_key(sort_key)}").except(:page))
        end
      else
        th(title, :class => classes)
      end
    end

      ## copied form ActiveAdmin
    # Returns an array for the current sort order
    #   current_sort[0] #=> sort_key
    #   current_sort[1] #=> asc | desc
    def current_sort
      @current_sort ||= if params[:order] && params[:order] =~ /^([\w\_\.]+)_(desc|asc)$/
        [$1,$2]
      else
        []
      end
    end

    # Returns the order to use for a given sort key
    #
    # Default is to use 'desc'. If the current sort key is
    # 'desc' it will return 'asc'
    def order_for_sort_key(sort_key)
      current_key, current_order = current_sort
      return 'desc' unless current_key == sort_key
      current_order == 'desc' ? 'asc' : 'desc'
    end

    def default_actions(*args)
      th { br }
    end

    def actions(*args)
      th { br }
    end
  end

  class BodyBuilder < ArBredElegate
    def initialize(base, record)
      @record = record
      super(base)
    end

    def column(name, options = {}, &block)
      value = block_given?? yield(@record) : @record.send(name)

      td value, :class => name.is_a?(Symbol)? name : ''
    end

    def method_missing(name, *args, &block)
      @base.send name, *args, &block
    end

      ## copied from active admin
    def actions(options = {}, &block)
      options = {
        :name => "",
        :defaults => true
      }.merge(options)
      td do
        text_node default_actions(:plain_text => true) if options[:defaults]
        text_node instance_exec(@resource, &block) if block_given?
      end
    end

    def default_actions(options = {})
      links = ''.html_safe
      if controller.action_methods.include?('show') && authorized?(ActiveAdmin::Auth::READ, @record)
        links << link_to(I18n.t('active_admin.view'), resource_path(@record), :class => "member_link view_link")
      end
      if controller.action_methods.include?('edit') && authorized?(ActiveAdmin::Auth::UPDATE, @record)
        links << link_to(I18n.t('active_admin.edit'), edit_resource_path(@record), :class => "member_link edit_link")
      end
      if controller.action_methods.include?('destroy') && authorized?(ActiveAdmin::Auth::DESTROY, @record)
        links << link_to(I18n.t('active_admin.delete'), resource_path(@record), :method => :delete, :data => {:confirm => I18n.t('active_admin.delete_confirmation')}, :class => "member_link delete_link")
      end

      options[:plain_text] ? links : td(links)
    end
  end

#                         <tbody>
#                           <tr class="odd" id="call_center_report_16">
#                             <td class="approved"><div class="div needs-review"><select data-path="/control/call_center_reports/16" name="approved"><option value="true">Одобрено</option><option value="false">Отклонено</option><option selected="" value="">Проверить</option></select></div></td>
#                             <td class="violation_type"><div><p class="violation_type_name">0.12. Не выдавали копию протокола (3.23)</p><select data-path="/control/call_center_reports/16" id="change_violation_type"><option value="1">ВЫБЕРИТЕ ТИП НАРУШЕНИЯ. ЖЕЛАТЕЛЬНО НЕ "ПРОЧИЕ".</option><option value="2">0.1. Наблюдателя/члена комиссии выгоняют с участка (2.14 в типологии «Голоса»)</option><option value="3">0.2. Наблюдателю угрожают</option><option value="4">0.3. Вброс бюллетеней (2.8)</option><option value="5">0.4. Карусель (2.8)</option><option value="6">0.5. Массовое голосование вне помещения</option><option value="7">0.6. Ограничение на перемещение наблюдателей по участку (2.11)</option><option value="8">0.7. Запрет на фото/видеосъемку (2.12)</option><option value="9">0.8. Присутствие на участке посторонних лиц</option><option value="10">0.9. Члены УИК подписывали незаполненный протокол (3.21)</option><option value="11">0.10. При подсчете данные не заносились сразу в увеличенную форму после каждого этапа подсчета (3.12)</option><option value="12">0.11. Отказ в принятии жалобы (3.19)</option><option value="13">0.12. Не выдавали копию протокола (3.23)</option><option value="14">0.13. Прочие нарушения</option><option value="15">0.14 Голосование по допспискам</option><option value="16">1.1. Трудности при доступе на участок</option><option value="17">1.2. Председатель УИК не предъявил пустые ящики для голосования</option><option value="18">1.3. Наблюдателям и членам с ПСГ не дали ознакомится со списком избирателей</option><option value="19">1.4. Членам УИК бюллетени выдаются не под роспись</option><option value="20">1.5. Трудности в получении информации</option><option value="21">2.2. Есть агитационные материалы на участке</option><option value="22">2.3. Нет сводного плаката</option><option value="23">2.4. У наблюдателей нет возможности видеть места выдачи бюллетеней, избирательные ящики, кабинки для голосования</option><option value="24">2.5. Нарушена процедура выдачи бюллетеней</option><option value="25">2.6. Подвоз избирателей</option><option value="26">2.7. Списки избирателей не прошиты</option><option value="27">2.9. Групповое голосование по открепительным</option><option value="28">2.10. Давление на избирателей</option><option value="29">2.13. Переносные ящики не в поле зрения наблюдателей</option><option value="30">2.15. Для выездного голосования используются списки, составленные организациями</option><option value="31">2.16. Не дают ознакомиться с реестром на голосование вне помещения</option><option value="32">2.17. Не дают присутствовать при голосовании вне помещения</option><option value="33">3.6. Не оглашались данные подсчета по каждой книге избирателей</option><option value="34">3.7. Наблюдателю отказали в возможности удостоверится в правильности подсчетов по спискам</option><option value="35">3.8. Не объявлялось количество заявлений на голосование вне помещения перед вскрытием каждого переносного ящика</option><option value="36">3.9, 3.10, 3.12, 3.13. Прочие нарушения при подсчете</option><option value="37">3.11. Наблюдатели не могли видеть отметки в бюллетенях при подсчете голосов</option></select></div></td>
#                             <td class="uic"></td>
#                             <td class="text">rfr4f</td>
#                             <td class="reporter">  </td>
#                             <td class="phone">4992703877</td>
#                             <td class="current_role"></td>
#                             <td class="created_at">07 сентября 2013, 18:24</td>
#                             <td class=""><a class="member_link view_link" href="/control/call_center_reports/16">Открыть</a><a class="member_link edit_link" href="/control/call_center_reports/16/edit">Изменить</a></td>
#                           </tr>
#                         </tbody>

end
