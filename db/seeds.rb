require 'faker'

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

admin3 = User.create!(
  email: 'smartlockerbrasiliarfid@rfid.com',
  name: "Administrador",
  lastname: "Master",
  phone: "453526-3939",
  cnpj: "26.958.914/0001-53",
  nameCompany: "Brasilia RFID",
  street: "Guara",
  city: "Brasilia",
  state: "Distrito Federal",
  zip_code: "85859-490",
  neighborhood: "Brazil",
  finance: "adimplente",
  role: 'admin',
  complement: "Casa 27",
  password: 'Rfid!@#',
  password_confirmation: 'Rfid!@#'
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

# Admin criando o Keylocker
locker = admin1.keylockers.create!(
  owner: 'Luiz Reis', 
  nameDevice: 'Brasilia RFID', 
  cnpjCpf: '27.928.993/0001-12', 
  qtd: 8, 
  serial: 'WEE7JSPHIA', 
  door: 'fechado', 
  status: 'desbloqueado', 
  lockertype: 'Armário de chaves',
  keylockerinfos_attributes: [
    { object: 'Laptop Dell Inspiron 15', posicion: 1, empty: 1, tagRFID: 'RFID-12345', idInterno: 'ID-001', description: 'Laptop para uso corporativo'},
    { object: 'Samsung Galaxy S21', posicion: 2, empty: 1, tagRFID: 'RFID-67890', idInterno: 'ID-002', description: 'Celular de última geração'},
    { object: 'GoPro HERO9 Black', posicion: 3, empty: 1, tagRFID: 'RFID-11223', idInterno: 'ID-003', description: 'Câmera de ação para esportes radicais' },
    { object: 'iPad Pro 11"', posicion: 4, empty: 1, tagRFID: 'RFID-44556', idInterno: 'ID-004', description: 'Tablet com performance de notebook'},
    { object: 'Nintendo Switch', posicion: 5, empty: 1, tagRFID: 'RFID-78901', idInterno: 'ID-005', description: 'Console portátil para jogos'},
    { object: 'Sony WH-1000XM4', posicion: 6, empty: 1, tagRFID: 'RFID-23456', idInterno: 'ID-006', description: 'Fones de ouvido com cancelamento de ruído'},
    { object: 'Canon EOS 90D', posicion: 7, empty: 1, tagRFID: 'RFID-34567', idInterno: 'ID-007', description: 'Câmera profissional DSLR'},
    { object: 'Smartwatch Garmin Forerunner 945', posicion: 8, empty: 1, tagRFID: 'RFID-45678', idInterno: 'ID-008', description: 'Relógio inteligente para atletas' }
  ]
)
puts 'Locker criado pelo admin'

# Atribuindo o Locker ao User
user.keylockers << locker
puts "Locker '#{locker.nameDevice}' atribuído ao usuário '#{user.email}'"

# Criando funcionário já com locker
locker_for_employee = user.keylockers.sample
  if locker_for_employee
    employee = user.create_employee!(
      name: "Luiz",
      lastname: "Reis",
      companyID: "Brasilia RFID",
      phone: "4599999-8888",
      email: "luizreis@brasiliarfid.com.br",
      function: "Operador",
      PIN: "8A60CA",
      cpf: "361.904.840-18",
      pswdSmartlocker: "6205",
      cardRFID: "816f1948",
      status: "ativo",
      delivery: false,
      enabled: false,
      keylockers: [locker_for_employee]
    )
    puts "Keylocker '#{employee.keylockers.last.nameDevice}' atribuído ao funcionário '#{employee.name}'"
    puts "Funcionário '#{employee.name} #{employee.lastname}' criado para o usuário '#{user.email}'"
  else
    puts "Erro: User '#{user.email}' não tem lockers atribuídos, não foi possível criar o employee"
  end

# Criando 4 keylockers com 8 nichos criativos e diferentes
Keylocker.create!(
  owner: 'Empresa A', 
  nameDevice: 'Sao Paulo RFID', 
  cnpjCpf: '98765432100', 
  qtd: 8, 
  serial: 'DEF456XYZ1', 
  door: 'fechado', 
  status: 'desbloqueado', 
  lockertype: ['Armário de chaves', 'Armário de encomendas', 'Guarda Volume'].sample,
  keylockerinfos_attributes: [
    { object: 'Microfone Wireless', posicion: 1, empty: 1 },
    { object: 'Câmera GoPro HERO', posicion: 2, empty: 1 },
    { object: 'Laptop Dell XPS', posicion: 3, empty: 1 },
    { object: 'Kindle Oasis', posicion: 4, empty: 1 },
    { object: 'Carregador portátil Anker', posicion: 5, empty: 1 },
    { object: 'AirPods Pro', posicion: 6, empty: 1 },
    { object: 'Roteador Wi-Fi Mesh', posicion: 7, empty: 1 },
    { object: 'Drone DJI Mavic Air', posicion: 8, empty: 1 }
  ]
)

Keylocker.create!(
  owner: 'TechSolutions', 
  nameDevice: 'Rio RFID', 
  cnpjCpf: '11223344557', 
  qtd: 8, 
  serial: 'GHI789XYZ2', 
  door: 'fechado', 
  status: 'desbloqueado', 
  lockertype: ['Armário de chaves', 'Armário de encomendas', 'Guarda Volume'].sample,
  keylockerinfos_attributes: [
    { object: 'Projetor Epson', posicion: 1, empty: 1 },
    { object: 'Monitor LG 27"', posicion: 2, empty: 1 },
    { object: 'Notebook HP Spectre', posicion: 3, empty: 1 },
    { object: 'Carregador de laptop MacBook', posicion: 4, empty: 1 },
    { object: 'Smartphone Samsung Galaxy S21', posicion: 5, empty: 1 },
    { object: 'Câmera de Segurança Arlo', posicion: 6, empty: 1 },
    { object: 'Powerbank Xiaomi', posicion: 7, empty: 1 },
    { object: 'Assinatura Netflix (cartão)', posicion: 8, empty: 1 }
  ]
)

Keylocker.create!(
  owner: 'Global Enterprises', 
  nameDevice: 'Salvador RFID', 
  cnpjCpf: '22334455678', 
  qtd: 8, 
  serial: 'JKL012XYZ3', 
  door: 'fechado', 
  status: 'desbloqueado', 
  lockertype: ['Armário de chaves', 'Armário de encomendas', 'Guarda Volume'].sample,
  keylockerinfos_attributes: [
    { object: 'Câmera Digital Sony', posicion: 1, empty: 1 },
    { object: 'Fones de ouvido Sennheiser', posicion: 2, empty: 1 },
    { object: 'Carregador rápido OnePlus', posicion: 3, empty: 1 },
    { object: 'Tablet Microsoft Surface', posicion: 4, empty: 1 },
    { object: 'Smartphone Xiaomi Mi 11', posicion: 5, empty: 1 },
    { object: 'Smartwatch Garmin Fenix', posicion: 6, empty: 1 },
    { object: 'Cartão de Memória SanDisk', posicion: 7, empty: 1 },
    { object: 'Drone DJI Phantom 4', posicion: 8, empty: 1 }
  ]
)

puts 'Lockers criado'

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
