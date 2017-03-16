export default {
  "home": {
    "headers": {
      "logoPrintUrl": '/gu_logo_en_high.png',
      "level1": 'Gothenburg University Library',
      "level2": 'Order',
      "mainHeader": 'Order articles and interlibrary loans',
    },
    "footer": {
      "content": '© <a title="Göteborgs universitet" href="http://www.gu.se/">University of Gothenburg, Sweden</a><br>Box 100, S-405 30 Gothenburg<br>Phone +46 31-786 0000, <a title="Contact" href="http://www.gu.se/omuniversitetet/kontakt/">Contact</a>'
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
    "404": "The page you were looking for does not exist.",
  },
  "login": {
    "casLogin": "Log in"
  },
  "request-errors": {
    "NO_ID": {
      "header": "Det saknas ett ID",
      "message": "Detta felet uppkommer eftersom applikationen laddas utan sitt dynamiska segment som krävs för rutten request. Felet fångas på application-nivå i before-model.",
    },
    "BANNED": {
      "header": "Avstängd!",
      "message": "Du är avstäng från Universitetsbiblioteket. Kontakta.... "
    },
    "CARD_LOST": {
      "header": "Ditt lånekort är anmält förlorat!",
      "message": "Då ditt lånekort är anmält som förlorat måste du ansöka om ett nytt. Kontakta.... "
    },
    "FINES": {
      "header": "Du har obetalda avgifter!",
      "message": "Dina sammanlagda avgifter överstiger högsta tillåtna belopp och måste korrigeras innan nya lån kan göras."
    },
    "DEBARRED": {
      "header": "Du har obetalda avgifter!",
      "message": "Dina sammanlagda avgifter högsta tillåtna belopp och måste korrigeras innan nya lån kan göras."
    },
    "NO_ADDRESS": {
      "header": "Adress saknas!",
      "message": "Det finns ingen angiven låntagaradress och det måste korrigeras innan nya lån kan göras."
    },
    "EXPIRED": {
      "header": "Utgånget lånekort",
      "message": "Ditt lånekort har gått ut och måste förnyas innan nya lån kan göras."
    },
    "CAN_NOT_BE_BORROWED": {
      "header": "Får ej lånas",
      "message": "Får ej lånas."
    },
    "ITEM_NOT_FOUND": {
      "header": "Hittas ej",
      "message": "Den efterfrågade posten hittades ej."
    },
    "ALREADY_BORROWED": {
      "header": "Redan lånad",
      "message": "Du har lånat ett exemplar av detta material."
    },
    "ALREADY_RESERVED": {
      "header": "Har redan köat eller beställt",
      "message": "Du har redan beställt detta material eller står i kö på det."
    },
  }
};