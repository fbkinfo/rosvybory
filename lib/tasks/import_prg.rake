require 'roo/excelx'


  desc 'Импорт расстановок ПРГ'
  task import_prg: :environment do
    col_map = [:adm, :district, :status, :uik, :source, :f, :i, :o, :phone, :email]

    puts "Parsing xlsx..."

    filename = 'docs/prg.xlsx'
    spreadsheet = Roo::Excelx.new(filename, nil, :ignore)

    rows = Enumerator.new do |y|
      (spreadsheet.first_row..spreadsheet.last_row).each { |i| y.yield spreadsheet.row(i); }
    end

    puts "Inserting values..."

    ActiveRecord::Base.transaction do
      index = 0
      rows.drop(1).each do |row|
        index += 1
        attrs = Hash[col_map.zip(row)]

        unless uic = Uic.find_by_number(attrs[:uik].to_i)
          puts "#{index}: УИК с номером #{attrs[:uik]} не найден"
          #p attrs
          next
        end

        unless region = Region.find_by_name(attrs[:district].try(:strip))
          puts "#{index}: Район #{attrs[:district]} не найден"
          #p attrs
          next
        end

        unless source = NominationSource.find_by_name(attrs[:source].try(:strip))
          puts "#{index}: Источник выдвижения #{attrs[:source]} не найден"
          #p attrs
          next
        end

        user = nil
        email = attrs[:email].try(:strip)
        phone = Verification.normalize_phone_number(attrs[:phone])
        if phone.blank?
          #puts "#{index}: Не указан телефон, ищу по email и фамилии"
          #p attrs
          user = User.find_by(email: email, last_name: attrs[:f].strip) if email.present?
          unless user
            puts "#{index}: Не найден пользователь с такими email и фамилией #{email} #{attrs[:f]}, телефон не указан"
            next
          end
        else
          unless user = User.find_by_phone(phone)
            #puts "#{index}: Не найден пользователь с телефоном #{phone}"
            user = User.find_by(email: email, last_name: attrs[:f].strip) if email.present?
            unless user
              puts "#{index}: Не найден пользователь с телефоном #{phone}, либо с email и фамилией: #{email} #{attrs[:f]}"
              next
            end
          end
        end

        if user.last_name.try(:strip).try(:lowercase) != attrs[:f].try(:strip).try(:lowercase)
          if user.email != email
            puts "#{index}: Ни фамилия, ни email не совпадают с указанными в БД! #{user.last_name} != #{attrs[:f]} ; #{user.email} != #{email} "
            #p attrs
            next
          end
        end
        prg_role = CurrentRole.where(slug: "prg").first!
        ucr = user.user_current_roles.find_by(current_role_id: prg_role.id)

        if ucr
          if ucr.uic && (ucr.uic != uic)
            puts "#{index}: У пользователя уже есть расстановка с ПРГ на другом УИК! #{ucr.uic.number}, а в файле -  #{uic.number}"
            #p attrs
            next
          end
          ucr.uic = uic

          if ucr.nomination_source && (ucr.nomination_source != source)
            puts "#{index}: У пользователя уже есть расстановка с ПРГ от другого источника выдвижения! #{ucr.nomination_source.name}, а в файле -  #{source.name}"
            #p attrs
            next
          end
          ucr.nomination_source = source

          if ucr.region && (ucr.region != region)
            puts "#{index}: У пользователя уже есть расстановка с ПРГ в другом районе! #{ucr.region.name}, а в файле -  #{region.name}"
            #p attrs
            next
          end
          ucr.region = region

          unless ucr.save
            puts "#{index}: Не удалось обновить расстановку: #{ucr.errors.full_messages.join('; ')}"
            #p attrs
            next
          end
        else
          ucr = user.user_current_roles.build(current_role_id: prg_role.id)
          ucr.uic = uic
          ucr.nomination_source = source
          ucr.region = region
          unless ucr.save
            puts "#{index}: Не удалось создать расстановку: #{ucr.errors.full_messages.join('; ')}"
            #p attrs
            next
          end
        end
      end
    end
  end
