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

# Criando 4 keylockers com 8 nichos criativos e diferentes

Keylocker.create!(
  owner: 'Luiz Reis', 
  nameDevice: 'Brasilia RFID', 
  cnpjCpf: '12345678909', 
  qtd: 6, 
  serial: 'ABC123XYZ9', 
  door: 'fechado', 
  status: 'desbloqueado', 
  lockertype: ['Armário de chaves', 'Armário de encomendas', 'Guarda Volume'].sample,
  keylockerinfos_attributes: [
    { object: 'Notebook Gamer', posicion: 1, empty: 1 },
    { object: 'Celular iPhone 14', posicion: 2, empty: 1 },
    { object: 'Câmera Canon EOS', posicion: 3, empty: 1 },
    { object: 'Kindle Paperwhite', posicion: 4, empty: 1 },
    { object: 'Tablet Samsung Galaxy', posicion: 5, empty: 1 },
    { object: 'Smartwatch Apple Watch', posicion: 6, empty: 1 },
    { object: 'SmartTV Samsung 55"', posicion: 7, empty: 1 },
    { object: 'Fones de ouvido Bose', posicion: 8, empty: 1 }
  ]
)

Keylocker.create!(
  owner: 'Empresa A', 
  nameDevice: 'Sao Paulo RFID', 
  cnpjCpf: '98765432100', 
  qtd: 6, 
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
  qtd: 6, 
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
  qtd: 6, 
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
