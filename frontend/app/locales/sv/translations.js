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
        "btnNext": "Fortsätt"
      },
      "details": {
        "header": "Din beställning",
        "labelForLoantypeDropdown": "Hur vill du låna?",
        "labelForLocationDropdown": "Var vill du hämta?",
        "btnNext": "Fortsätt"
      },
      "confirmation": {
        "confirmation-header": "Tack för din beställning",
        "you-have-place": "Du har plats",
        "in-queue": "i kön",
        "message": "Du får ett meddelande när materialet finns att hämta på",
        "my-loans-link-text": "Mina lån - se dina lån och beställningar"

      },
      "summary": {}
    }
  },
  "status-errors": {
    "404": "Vi hittade tyvärr inte posten du sökte.",
  },
  "login": {
    "casLogin": "Log in"
  },
  "request-errors": {
    "header": "Det går inte att beställa",
    "NO_ID": {
      "message": "Detta felet uppkommer eftersom applikationen laddas utan sitt dynamiska segment som krävs för rutten request. Felet fångas på application-nivå i before-model.",
    },
    "BANNED": {
      "message": "Du är avstängd från bibliotekets tjänster. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> om du har frågor om detta."
    },
    "CARD_LOST": {
      "message": "Ditt bibliotekskort/konto är spärrat. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "FINES": {
      "message": "Du har för höga förseningsavgifter. Besök något av <a href=\"http://www.ub.gu.se/bibliotek/\">biblioteken</a> för att betala din avgift."
    },
    "DEBARRED": {
      "message": "Du får inte beställa. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "NO_ADDRESS": {
      "message": "Vi saknar adressuppgifter till dig. Fyll i din adress i <a href=\"#\">Mina lån</a>."
    },
    "EXPIRED": {
      "message": "Giltighetstiden på ditt bibliotekskort har gått ut. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att uppdatera kortet."
    },
    "CAN_NOT_BE_BORROWED": {
      "message": "Det här materialet går inte att beställa eller låna hem. Du kan hämta boken från hyllan och läsa på plats i biblioteket."
    },
    "ITEM_NOT_FOUND": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "ALREADY_BORROWED": {
      "message": "Du har redan lånat materialet."
    },
    "ALREADY_RESERVED": {
      "message": "Du har redan beställt eller köar på materialet."
    },
    "NOT_FOUND": {
      "message": "Du är inte registrerad för att få låna på biblioteket. Ansök om ett bibliotekskort här."
    },

    "UNKNOWN_ERROR": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    }
  },
  "confirmation-errors": {
    "header": "Det gick inte att beställa",

    "DAMAGED": {
      "message": "Materialet är skadat och kan inte beställas. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "AGE_RESTRICTED": {
      "message": "Du får inte beställa det här materialet. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "ITEM_ALREADY_ON_HOLD": {
      "message": "Du har redan beställt eller köar på materialet."
    },
    "TOO_MANY_RESERVES": {
      "message": "Du har för många lån för att få beställa."
    },
    "NOT_RESERVABLE": {
      "message": "Materialet kunde inte beställas. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "CANNOT_RESERVE_FROM_OTHER_BRANCHES": {
      "message": "Materialet kunde inte beställas till andra bibliotek."
    },
    "TOO_MANY_HOLDS_FOR_THIS_RECORD": {
      "message": "Det gick inte att beställa det här materialet. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "BORROWER_NOT_FOUND": {
      "message": "Du är inte registrerad för att få låna på biblioteket. Ansök om ett bibliotekskort <a href=\"http://www.ub.gu.se/lana/kort/\"här</a>."
    },
    "BRANCH_CODE_MISSING": {
      "message": "Du måste ange ett bibliotek att hämta materialet på."
    },
    "ITEMNUMBER_OR_BIBLIONUMBER_IS_MISSING": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "BIBLIONUMBER_IS_MISSING": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "ITEM_DOES_NOT_BELONG_TO_BIBLIO": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "UNRECOGNIZED_ERROR": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "MISSING_USER": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "MISSING_LOCATION": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "MISSING_BIBLIO": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "MISSING_LOAN_TYPE": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    }
  }
};