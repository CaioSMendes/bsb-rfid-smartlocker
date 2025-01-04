# app/views/api/v1/keylockers/index.json.jbuilder
json.array!(@key_lockers) do |key_locker|
  json.id key_locker.id
  json.owner key_locker.owner
  json.nameDevice key_locker.nameDevice
  json.ipAddress key_locker.ipAddress
  json.status key_locker.status
  # Adicione outros atributos conforme necessário
end
