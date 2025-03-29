// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./channels"
import Chartkick from "chartkick"
import Chart from "chart.js"

// Configura o Chartkick para usar o Chart.js
Chartkick.addAdapter(Chart)


import { createConsumer } from "@rails/actioncable"

// Substitua o código abaixo pelo seu serial de locker, por exemplo, no código ERB você pode passá-lo como um dado dinamicamente
document.addEventListener("DOMContentLoaded", () => {
  const keyId = document.getElementById('key_id').textContent; // Supondo que você tenha o serial do locker na sua view
  const channel = createConsumer().subscriptions.create({ channel: "HistoryChannel", key_id: keyId }, {
    received(data) {
      // Atualize a página com os dados recebidos
      const tableBody = document.querySelector('tbody');
      const newRow = document.createElement('tr');
      
      newRow.innerHTML = `
        <td>${data.employee_name}</td>
        <td>${data.action}</td>
        <td>${data.key_id}</td>
        <td>${data.locker_name}</td>
        <td>${data.timestamp}</td>
        <td>${data.status}</td>
        <td>${data.comments}</td>
        <td>
          ${data.alert ? '<button class="btn btn-danger">Alerta: Devolução não realizada</button>' : ''}
        </td>
      `;
      tableBody.appendChild(newRow);
    }
  });
});
