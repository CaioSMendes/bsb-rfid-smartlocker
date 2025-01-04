// app/javascript/packs/application.js

import 'intl-tel-input';
import 'intl-tel-input/build/js/utils';
import 'intl-tel-input/build/css/intlTelInput.css';

document.addEventListener('turbolinks:load', function() {
  var input = document.querySelector("#user_phone"); // Certifique-se de substituir "user_phone" pelo ID real do seu campo de telefone
  var iti = window.intlTelInput(input, {
    separateDialCode: true,
    utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.13/js/utils.js",
  });

  // Atualize a bandeira ao carregar a página, se necessário
  var countryCode = iti.getSelectedCountryData().iso2;
  document.querySelector("#phone-flag").innerHTML = `<img src="https://cdnjs.cloudflare.com/ajax/libs/flag-icon-css/3.5.0/flags/1x1/${countryCode}.svg" alt="${countryCode.toUpperCase()}">`;

  // Atualize a bandeira quando o país for alterado
  input.addEventListener('countrychange', function() {
    var countryCode = iti.getSelectedCountryData().iso2;
    document.querySelector("#phone-flag").innerHTML = `<img src="https://cdnjs.cloudflare.com/ajax/libs/flag-icon-css/3.5.0/flags/1x1/${countryCode}.svg" alt="${countryCode.toUpperCase()}">`;
  });
});
