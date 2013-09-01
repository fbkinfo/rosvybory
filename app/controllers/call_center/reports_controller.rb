# encoding: utf-8

class CallCenter::ReportsController < ApplicationController
  layout "call_center"

  def new
    @report = CallCenter::Report.new
    @report.reporter = CallCenter::Reporter.new
    @uic_reports = [
      {time: 1.minute.ago, violation: nil, text: "в ТИК алтуфьевский нарушения правил приема протоколов из уик - все рассосались по комнатам в управе и никого невозможно найти несколько часов"},
      {time: 2.hours.ago, violation: "Вброс", text: "не заполнялась увеличенная форма протокола. Предс и секретарь и др члены комиссии уединились и колдуют над цифрами протокола. При этом происходят телефонные переговоры (с ТИК?). Наблюдатели собираются подавать жалобу в ТИК."},
      {time: 1.days.ago, violation: "Вброс", text: "В УИКе не дали возможности видеть отметки в бюллетенях. Не допустили к участию в подсчете голосов. Подал жалобу в ТИК. В ТИКе жалобу приняли, но волокитят с рассмотрением. Отказываются дать ответ."}]
  end

  def create
    @report = CallCenter::Report.create(report_params)
  end

  def update
  end

  private
    def report_params
      params.require(:call_center_report).permit(reporter_attributes: [:phone, :dislocation,
        :uic, :role, { report: [:text, violation: [:violation_type] ] }, :parent_report_ids ])
    end
end
