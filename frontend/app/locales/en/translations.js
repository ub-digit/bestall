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
    "item-order-button": {
      "queue": "Queue",
      "order": "Order"
    },
    "item-table": {
      "volume": "Volume",
      "location": "Location",
      "status": "Status",
      "must_be_ordered": "Must be ordered",
      "available": "Available",
      "not_for_home_loan": "Ej hemlån",
      "reading_room_only": "Beställs till läsesal",
      "loan_in_house_only": "Utlån endast på plats",
      "loaned": "Utlånad till",
      "reserved": "Reserverad",
      "waiting": "Waiting for avhämtning",
      "in_transit": "In transit",
      "delayed": "Delayed",
      "under_acquisition": "Under inköp",
      "not_in_place": "Ej på plats",
      "unknown": "Unknown",
    },
    "pick-location": {
      "cannot-pickup-here" : "Kan ej beställas hit"
    },
    "pick-type-of-loans": {
      "not-allowed": "Ej tillåtet"
    },
    "progress-steps": {
      "step-items-label": "Items",
      "step-details-label": "Your order",
      "step-summary-label": "Summary",
      "step-confirmation-label": "Confirmation"
    },
    "toggle-lang": {
      "language": {
        "sv": "Svenska",
        "en": "English",
      }
    }
  },
  "request": {
    "order": {
      "header": "My order",
      "items": {
        "next-button": "Continue",
        "select-button": "Select",
        "location": "Location",
        "note": "Note",
        "items": "Items",
        "subscriptions": "Subscriptions",
        "available": "Available",
        "not-available": "Not available",
        "currently-no-available-items": "Currently there are no available items.",
        "number-of-people-in-queue": "personer i kö på utlånade exemplar",
        "queue-up": "Ställ dig i kö",
        "all-items-are-available": "Alla exemplar finns tillgängliga."
      },
      "details": {
        "header": "Din beställning",
        "loantype-dropdown-label": "Hur vill du låna?",
        "location-dropdown-label": "Var vill du hämta?",
        "next-button": "Fortsätt",
        "cant-be-pickedup-here": "Kan ej beställas hit",
        "not-allowed": "Ej tillåtet",
        "subscription-reserve-label": "Detaljer om beställningen",
        "subscription-reserve-helptext": "Ange volym, år och nummer eller sidnummer för det exemplar du vill beställa.",
        "subscription-note": "Du kan beställa exemplar ur följande bestånd:",
        "reserve-label": "Kommentarer (valfri)",
        "reserve-helptext": "Ange om det är något mer du tror att vi behöver veta om din beställning.",
        "goback-button": "Tillbaka"
      },
      "confirmation": {
        "header": "Tack för din beställning",
        "error-header": "Det gick inte att beställa",
        "you-have-place": "Du har plats",
        "in-queue": "i kön",
        "message": "Du får ett meddelande när materialet finns att hämta på",
        "my-loans-link-text": "Mina lån - se dina lån och beställningar"
      },
      "summary": {
        "copy-number": "Exemplar",
        "loantype": "Typ av lån",
        "pickup-location": "Hämta på",
        "reserve-notes": "Kommentar",
        "subscription-notes": "Kommentar",
        "goback-button": "Tillbaka",
        "submit-order-button": "Beställ"
      }
    }
  },
  "status-errors": {
    "404": "The page you were looking for does not exist.",
  },
  "login": {
    "casLogin": "Log in"
  },
  "request-errors": {
    "header": "Unable to order",
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
      "message": "Du har allaredan beställt eller köar på materialet."
    },
    "NOT_FOUND": {
      "message": "Du är inte registrerad för att få låna på biblioteket. Ansök om ett bibliotekskort här."
    },
    "UNAUTHORIZED": {
      "message": "unauthorized..."
    },
    "UNKNOWN_ERROR": {
      "message": "Något gick fel. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    }
  },
  "confirmation-errors": {
    "header": "Unable to order",

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
      "message": "Du har för många reservationer för att få beställa."
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
