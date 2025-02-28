// app/javascript/channels/history_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "HistoryChannel", keylocker_serial: "P2MUZUINB7" }, {
  received(data) {
    // Atualiza a tabela com os dados recebidos
    const tbody = document.querySelector("table tbody");
    const newRow = document.createElement("tr");
    
    newRow.innerHTML = `
      <td>${data.employee_name}</td>
      <td>${data.action}</td>
      <td>${data.key_id}</td>
      <td>${data.locker_name}</td>
      <td>${data.timestamp}</td>
      <td>${data.status}</td>
      <td>${data.comments}</td>
      <td>${data.alert ? "<button class='btn btn-danger'>Alerta: Devolução não realizada</button>" : ""}</td>
    `;
    tbody.appendChild(newRow);
  }
});