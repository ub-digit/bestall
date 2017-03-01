export default {

  "home": {
    "headers": {
      "logoPrintUrl": '/gu_logo_sv_high.png',
      "level1": 'Göteborgs universitetsbibliotek',
      "level2": 'Beställ',
      "mainHeader": 'Beställ',
    },
    "footer": {
      "content": '© <a title="Göteborgs universitet" href="http://www.gu.se/">Göteborgs universitet</a><br>Box 100, 405 30 Göteborg<br>Tel. 031-786 0000, <a title="Kontakta oss" href="http://www.gu.se/omuniversitetet/kontakt/">Kontakta oss</a>'
    },
  },
  "components": {
    "toggle-lang": {
      "language": {
        "sv": "Svenska",
        "en": "English",
      }
    },
    "progress-steps": {
      "step-items-label": "Exemplar",
      "step-details-label": "Din beställning",
      "step-summary-label": "Sammanfattning",
      "step-confirmation-label": "Bekräftelse"
    }
  },
  "request": {
    "order": {
      "header": "Min beställning",
      "items": {
        "btnNext": "Nästa"
      },
      "details": {
        "header": "Din beställning",
        "labelForLoantypeDropdown": "Välj typ av lån",
        "labelForLocationDropdown": "Välj upphämntningsställe",
        "btnNext": "Nästa"
      },
      "confirmation": {

      },
      "summary": {

      }
    }
  },

  "status-errors" : {
    "404": "Vi hittade tyvärr inte posten du sökte.",
  },
  "request-errors" : {
    "NO_ID" : "Det saknas ett ID",
    "BANNED" : {"header" : "Avstängd!",
              "message" : "Du är avstäng från Universitetsbiblioteket. Kontakta.... "
    },
    "CARD_LOST" : {"header" : "Ditt lånekort är anmält förlorat!",
                "message" : "Då ditt lånekort är anmält som förlorat måste du ansöka om ett nytt. Kontakta.... "
    },
    "FINES" :  {"header" : "Du har obetalda avgifter!",
              "message" : "Dina sammanlagda avgifter överstiger högsta tillåtna belopp och måste korrigeras innan nya lån kan göras."
    },
    "DEBARRED" : {"header" : "Du har obetalda avgifter!",
                "message" : "Dina sammanlagda avgifter högsta tillåtna belopp och måste korrigeras innan nya lån kan göras."
    },
    "NO_ADDRESS" : {"header" : "Adress saknas!",
                  "message" : "Det finns ingen angiven låntagaradress och det måste korrigeras innan nya lån kan göras."
    },
    "EXPIRED" : {"header" : "Utgånget lånekort",
                "message" : "Ditt lånekort har gått ut och måste förnyas innan nya lån kan göras."
    }
  }
};
