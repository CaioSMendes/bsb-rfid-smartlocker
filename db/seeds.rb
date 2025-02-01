require 'faker'

def generate_pswdSmartlockerOLD
  digits = (1..9).to_a
  letters = ('A'..'D').to_a
  (digits.sample(4) + letters.sample(4)).shuffle.join
end

def generate_pswdSmartlocker
  (0..9).to_a.sample(4).join
end

# Função auxiliar para gerar um horário formatado
def formatted_time(time)
  time.strftime("%H:%M")
end

# Crie um usuário administrador
admin1 = User.create!(
  email: 'admin@admin.com',
  name: "Caio",
  lastname: "Mendes",
  phone: "453526-3939",
  cnpj: "26.958.914/0001-53",
  nameCompany: "Lex Corporate",
  street: "Foz do Iguaçu",
  city: "Foz do Iguaçu",
  state: "Paraná",
  zip_code: "85859-490",
  neighborhood: "Brazil",
  finance: "adimplente",
  role: 'admin',
  complement: "Casa 27",
  password: 'admin123',
  password_confirmation: 'admin123'
)

admin2 = User.create!(
  email: 'ronaldo@ronaldo.com',
  name: "Ronaldo",
  lastname: "Nazario",
  phone: "453526-3939",
  cnpj: "26.958.914/0001-53",
  nameCompany: "Lex Corporate",
  street: "Foz do Iguaçu",
  city: "Foz do Iguaçu",
  state: "Paraná",
  zip_code: "85859-490",
  neighborhood: "Brazil",
  finance: "adimplente",
  role: 'admin',
  complement: "Casa 27",
  password: 'aaa123',
  password_confirmation: 'aaa123'
)

puts 'Admins criados'

# Crie um usuário regular
user = User.create!(
  email: 'user@user.com',
  name: "Caio",
  lastname: "Mendes",
  phone: "453526-3939",
  cnpj: "26.958.914/0001-53",
  nameCompany: "Lex Corporate",
  street: "Foz do Iguaçu",
  city: "Foz do Iguaçu",
  state: "Paraná",
  zip_code: "85859-490",
  neighborhood: "Brazil",
  finance: "adimplente",
  role: 'user',
  complement: "Casa 27",
  password: 'user123',
  password_confirmation: 'user123'
)
puts 'User criado'

# Passo 1: Criar 10 usuários
users_with_keylockers = []

10.times do |i|
  user = User.new(
    email: Faker::Internet.email,
    name: Faker::Name.first_name,
    lastname: Faker::Name.last_name,
    phone: Faker::PhoneNumber.phone_number,
    cnpj: Faker::Company.brazilian_company_number,
    nameCompany: Faker::Company.name,
    street: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: Faker::Address.zip_code,
    neighborhood: Faker::Address.community,
    finance: 'adimplente',
    role: 'user',
    complement: Faker::Address.secondary_address,
    password: 'user123',
    password_confirmation: 'user123'
  )

  if user.save
    # Para o primeiro usuário, criar um Keylocker manualmente
    if users_with_keylockers.empty?
      keylocker = Keylocker.new(
        owner: 'Luiz Reis',  # Nome manual
        nameDevice: 'Brasilia RFID',  # Modelo manual
        cnpjCpf: '12345678909',  # CPF manual
        qtd: 6,  # Quantidade manual
        serial: 'ABC123XYZ9',  # Serial manual
        door: 'fechado',  # Status da porta manual
        status: 'desbloqueado',  # Status manual
        lockertype: ['Armário de chaves', 'Armário de encomendas', 'Guarda Volume'].sample,
        keylockerinfos_attributes: [
          { object: 'Notebook', posicion: 1, empty: 0 },
          { object: 'Celular', posicion: 2, empty: 1 },
          { object: 'Câmera', posicion: 3, empty: 0 },
          { object: 'Kindle', posicion: 4, empty: 0 },
          { object: 'Tablet', posicion: 5, empty: 0 },
          { object: 'SmartWatch', posicion: 6, empty: 0 },
          { object: 'SmartTV', posicion: 7, empty: 0 },
          { object: 'Tablet', posicion: 8, empty: 0 }

        ]
      )

      if keylocker.save
        UserLocker.create!(user: user, keylocker: keylocker)
        puts "Criado UserLocker manualmente para User ID #{user.id} e Keylocker ID #{keylocker.id}"
        users_with_keylockers << user
      else
        puts "Erro ao criar Keylocker: #{keylocker.errors.full_messages.join(', ')}"
      end
    else
      # Para os demais usuários, decidir aleatoriamente se eles recebem um Keylocker
      if Faker::Boolean.boolean
        keylocker = Keylocker.new(
          owner: Faker::Name.name,
          nameDevice: Faker::Device.model_name,
          cnpjCpf: Faker::IDNumber.brazilian_citizen_number,
          qtd: 8,          
          serial: Faker::Alphanumeric.alphanumeric(number: 10),
          door: ['aberto', 'fechado'].sample,
          status: ['desbloqueado', 'bloqueado'].sample,
          lockertype: ['Armário de chaves', 'Armário de encomendas', 'Guarda Volume'].sample,
          keylockerinfos_attributes: Array.new(8) do |i|
            {
              object: Faker::Appliance.equipment,
              posicion: i + 1,
              empty: [0, 1].sample
            }
          end
        )

        if keylocker.save
          UserLocker.create!(user: user, keylocker: keylocker)
          puts "Criado UserLocker para User ID #{user.id} e Keylocker ID #{keylocker.id}"
          users_with_keylockers << user
        else
          puts "Erro ao criar Keylocker: #{keylocker.errors.full_messages.join(', ')}"
        end
      end
    end
  else
    puts "Erro ao criar usuário: #{user.errors.full_messages.join(', ')}"
  end
end

puts "#{Keylocker.count} Keylockers criados com seus respectivos Nichos!"


# Passo 2: Criar funcionários para usuários com Keylockers
users_with_keylockers.each do |user|
  number_of_employees = Faker::Number.between(from: 6, to: 10)

  puts "Criando funcionários para o usuário #{user.email} (ID: #{user.id})"

  number_of_employees.times do
    employee = Employee.new(
      name: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      email: Faker::Internet.email,
      companyID: Faker::Company.brazilian_company_number,
      phone: Faker::PhoneNumber.phone_number,
      function: Faker::Job.title,
      cpf:Faker::IDNumber.brazilian_citizen_number,
      PIN: Faker::Number.number(digits: 6),
      pswdSmartlocker: generate_pswdSmartlocker,
      cardRFID: Faker::Alphanumeric.alphanumeric(number: 10),
      status: ['active', 'inactive'].sample,
      delivery: [true, false].sample,
      enabled: [true, false].sample,
      user: user,
      profile_picture: nil,
      workdays_attributes: Array.new(Faker::Number.between(from: 1, to: 10)) do |i|
        {
          start: Faker::Time.between(from: DateTime.now.beginning_of_day, to: DateTime.now.middle_of_day, format: :short), # Horário de início
          end: Faker::Time.between(from: DateTime.now.middle_of_day, to: DateTime.now.end_of_day, format: :short),         # Horário de fim
          monday: Faker::Boolean.boolean,
          tuesday: Faker::Boolean.boolean,
          wednesday: Faker::Boolean.boolean,
          thursday: Faker::Boolean.boolean,
          friday: Faker::Boolean.boolean,
          saturday: Faker::Boolean.boolean,
          sunday: Faker::Boolean.boolean,
          enabled: Faker::Boolean.boolean
        }
      end
    )

    # Associar ao menos um Keylocker ao funcionário
    employee.keylockers << user.keylockers.sample

    if employee.save
      puts "Criado funcionário #{employee.name} (ID: #{employee.id}) com #{employee.workdays.count} dias de trabalho e #{employee.keylockers.count} Keylockers associados!"
    else
      puts "Erro ao criar funcionário: #{employee.errors.full_messages.join(', ')}"
    end
  end
end

puts "#{Employee.count} funcionários criados com seus respectivos dias de trabalho e Keylockers associados!"


# Criar Logs
Keylocker.all.each do |keylocker|
  if keylocker.employees.empty?
    next
  end

  keylocker.employees.each do |employee|
    20.times do |i|
      # Define os estados e a ação correspondente
      old_state = [0, 1].sample
      new_state = (old_state == 1 ? 0 : 1)
      action = (old_state == 1 && new_state == 0) ? "retirada" : "devolução"

      # Define a posição do locker de forma aleatória (1 a 8)
      position = rand(1..8)

      # Gera timestamps
      if i < 5
        # Para 5 logs, cria timestamps com mais de 24 horas
        timestamp_entry = Faker::Time.backward(days: 5, period: :morning)
        timestamp_exit = timestamp_entry + 1.day + rand(1..5).hours
      else
        # Para os outros 15 logs, cria timestamps recentes
        timestamp_entry = Faker::Time.backward(days: 1, period: :evening)
        timestamp_exit = timestamp_entry + 1.day + rand(1..5).hours
      end

      begin
        # Cria o log para o Employee e Keylocker em questão
        log = Log.create!(
          employee_id: employee.id,
          action: action,
          key_id: keylocker.serial,
          locker_name: keylocker.nameDevice,
          timestamp: (action == "retirada" ? timestamp_exit : timestamp_entry),
          status: (new_state == 1 ? "Ocupado" : "Disponível"),
          comments: "Chave #{position} registro de #{action} por #{employee.email}"
        )
        puts "Log #{i + 1} criado com sucesso"
      rescue StandardError => e
        puts "ERRO ao criar Log #{i + 1}: #{e.record.errors.full_messages.join(", ")}"
      end
    end
  end
end
puts "Configuração de Logs criada com sucesso."

10.times do
  Deliverer.create(
    name: Faker::Name.first_name,               # Nome aleatório
    lastname: Faker::Name.last_name,             # Sobrenome aleatório
    serial: Faker::Alphanumeric.alphanumeric(number: 10), # Serial aleatório (10 caracteres)
    phone: Faker::PhoneNumber.cell_phone,       # Telefone aleatório
    email: Faker::Internet.email,                # E-mail aleatório
    cpf: Faker::Number.leading_zero_number(digits: 11),  # CPF aleatório com 11 dígitos
    pin: Faker::Number.number(digits: 6),        # PIN aleatório com 6 dígitos
    keylocker_id: rand(1..10),                   # ID de keylocker aleatório entre 1 e 10
    enabled: Faker::Boolean.boolean             # Status habilitado (true ou false)
  )
end
puts "Entregadores Delivery Criado com sucesso."


# Exemplo de configuração de e-mail
EmailSetting.create!(
  address:              'smtp.gmail.com',
  port:                 465,
  user_name:            'smartmailbuilding@gmail.com',
  password:             'ebzzwrvykwihempj',
  authentication:       'plain',
  enable_starttls_auto: true,
  tls:                  true
)
puts "Configuração de email criada com sucesso."

# Criando apenas um registro
Sendsms.create!(
  user: "caiera96",
  password: "spiderpig1996",
  msg: "Brasilia RFID ! O seu PIN e",
  hashSeguranca: "2TISJUKTTXKSP_VNAPOXRW:MI1NE4LDASNYT-8J7RRLPS8NCC-SIMN64SDZYFZ--WU",
  url: "http://api.facilitamovel.com.br/api/simpleSend.ft"
)
puts "Configuração de SMS criada com sucesso."

puts 'SEED finalizada'
