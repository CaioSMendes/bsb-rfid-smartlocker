class ToggleDoorJob < ApplicationJob
  queue_as :default  # ou qualquer outra fila que você queira usar

  def perform(keylocker_id)
    keylocker = Keylocker.find_by(id: keylocker_id)

    if keylocker.present?
      keylocker.door = "aberto"
      keylocker.save

      # Aguarda 5 segundos (5000 milissegundos)
      sleep(5)

      keylocker.door = "fechado"
      keylocker.save
    else
      Rails.logger.error("Keylocker não encontrado com o ID: #{keylocker_id}")
    end
  end
end
