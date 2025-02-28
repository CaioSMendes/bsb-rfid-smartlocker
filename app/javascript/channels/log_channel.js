import consumer from "./consumer"

consumer.subscriptions.create({ channel: "LogChannel", key_id: document.getElementById('key_id').textContent }, {
  received(data) {
    // Atualiza a tabela com os dados recebidos
    const tableBody = document.querySelector('tbody');
    const newRow = document.createElement('tr');
    
    newRow.innerHTML = `
      <td>${data.log.employee.name} ${data.log.employee.lastname}</td>
      <td>${data.log.action}</td>
      <td>${data.log.key_id}</td>
      <td>${data.log.locker_name}</td>
      <td>${new Date(data.log.timestamp).toLocaleString()}</td>
      <td>${data.log.status}</td>
      <td>${data.log.comments}</td>
      <td>
        ${data.alert ? '<button class="btn btn-danger">Alerta: Devolução não realizada</button>' : ''}
      </td>
    `;
    tableBody.appendChild(newRow);
  }
});