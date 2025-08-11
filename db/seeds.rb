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
    { object: 'Ferrari 458 Italia', posicion: 1, empty: 1, tagRFID: '04A2B1C3D4E5F607', idInterno: 'ABC-1234', description: '4.5 V8 GASOLINA F1-DCT'},
    { object: 'Audi RS6', posicion: 2, empty: 1, tagRFID: '04B5C6D7E8F9A0B1', idInterno: 'XYZ-5678', description: '4.0 AVANT V8 32V BI-TURBO GASOLINA 4P TIPTRONIC'},
    { object: 'Porsche 911 Turbo S', posicion: 3, empty: 1, tagRFID: '04F2A3B4C5D6E7F8', idInterno: 'QWE-9876', description: '3.8 24V H6 GASOLINA TURBO S PDK'},
    { object: 'BMW M2 Competition', posicion: 4, empty: 1, tagRFID: '05D4E3F2A1B6C7D9', idInterno: 'JKL-4321', description: 'BMW M2 COMPETITION 3.0 BI-TURBO 410CV C/TETO AUT./2019'},
    { object: 'Mercedes AMG GT-S', posicion: 5, empty: 1, tagRFID: '06C8D9E0F1A2B3C4', idInterno: 'MNB-2468', description: 'Mercedes-benz Amg Gt-s 4.0bi-tb 510cv Aut.2015'},
    { object: 'Ducati Panigale', posicion: 6, empty: 1, tagRFID: '07F1A9B2C3D4E5F7', idInterno: 'POI-1357', description: 'Ducati Panigale 1199 195cv 2014'},
    { object: 'Dodge RAM 3500', posicion: 7, empty: 1, tagRFID: '08E0D2C1B3A4F6B8', idInterno: 'RST-8642', description: '6.7 I6 TURBO DIESEL LARAMIE CD 4X4 AUTOMÁTICO'},
    { object: 'Nissan GTR', posicion: 8, empty: 1, tagRFID: '09B5F6A7C8E0D1F9', idInterno: 'DFG-1230', description: '3.8 PREMIUM V6 24V BI-TURBO GASOLINA 2P AUTOMÁTICO'}
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
