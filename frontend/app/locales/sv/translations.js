export default {
  "home": {
    "title": "Beställ",
    "closed-info": "Just nu är biblioteken stängda för allmänheten. Beställningar och hämtningar av material kan därför inte göras av allmänheten.",
    "headers": {
      "logoPrintUrl": '/gu_logo_sv_high.png',
      "level1": 'Göteborgs universitetsbibliotek',
      "level2": 'Beställ och köa',
      "mainHeader": 'Beställ och köa',
    },
    "footer": {
      "content": '© <a title="Göteborgs universitet" href="http://www.gu.se/">Göteborgs universitet</a><br>Box 100, 405 30 Göteborg<br>Tel. 031-786 0000, <a title="Kontakta oss" href="http://www.gu.se/omuniversitetet/kontakt/">Kontakta oss</a>'
    },
  },
  "components": {
    "item-order-button": {
      "queue": "Köa",
      "order": "Beställ",
      "collect": "Hämta själv från hyllan"
    },
    "item-table": {
      "volume": "Exemplar",
      "location": "Placering",
      "status": "Status",
      "must_be_ordered": "Måste beställas",
      "available": "Tillgänglig",
      "not_for_home_loan": "Ej hemlån",
      "reading_room_only": "Läsesalslån, ej hemlån",
      "loan_in_house_only": "Endast utlån på plats",
      "loaned": "Utlånad till",
      "reserved": "Reserverad",
      "waiting": "Väntar på avhämtning",
      "in_transit": "Under transport",
      "delayed": "Försenad",
      "under_acquisition": "Under inköp",
      "not_in_place": "Ej på plats",
      "unknown": "Okänd",
    },
    "pick-location": {
      "cannot-pickup-here": "kan ej beställas hit",
      "library-closed": "stängt",
      "cannot-temporary-pickup-here": "kan ej beställas hit",
    },
    "pick-type-of-loans": {
      "not-allowed": "ej tillåtet"
    },
    "progress-steps": {
      "step-items-label": "Exemplar",
      "step-details-label": "Detaljer",
      "step-summary-label": "Summering",
      "step-confirmation-label": "Bekräftelse"
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
      "header": "Din beställning",
      "items": {
        "items-are-available": "Det finns tillgängliga exemplar som du kan beställa",
        "kursbok-is-available": "Det finns tillgängliga exemplar som du kan hämta själv från hyllan",
        "next-button": "Fortsätt",
        "select-button": "Välj",
        "order-subscription-button": "Beställ",
        "unspecified-holdings": "Ospecificerat bestånd",
        "location": "Placering",
        "note": "Bestånd",
        "items": "Exemplar",
        "subscriptions": "Bestånd",
        "available": "Tillgängliga",
        "not-available": "Utlånade",
        "currently-no-available-items": "Det finns inga tillgängliga exemplar just nu.",
        "number-of-people-in-queue": "personer i kö på utlånade exemplar",
        "queue-up": "Ställ dig i kö",
        "all-items-are-available": "Alla exemplar är tillgängliga.",
        "cant-be-ordered": "Går inte att beställa"
      },
      "details": {
        "header": "Din beställning",
        "loantype-dropdown-label": "Hur vill du låna?",
        "location-dropdown-label": "Var vill du hämta?",
        "next-button": "Fortsätt",
        "cant-be-pickedup-here": "kan ej beställas hit",
        "not-allowed": "ej tillåtet",
        "subscription-reserve-label": "Detaljer om beställningen (obligatoriskt)",
        "subscription-reserve-helptext": "Ange volym, år, nummer eller sidnummer för det exemplar du vill beställa.",
        "subscription-note": "Du kan beställa exemplar ur följande bestånd:",
        "reserve-label": "Eventuell övrig information om beställningen",
        "reserve-placeholder": "Till exempel: volym, nummer, tryckår",
        "reserve-helptext": "Informationen i detta fält skrivs ut. Skriv inte personuppgifter här. <a href=\"https://www.ub.gu.se/sv/kontakta-oss\" target=\"blank\">Kontakta biblioteket om du har frågor som rör din beställning.</a>",
        "goback-button": "Tillbaka"
      },
      "confirmation": {
        "header": "Tack för din beställning!",
        "error-header": "Det gick inte att beställa.",
        "you-have-place": "Du har plats",
        "in-queue": "i kön.",
        "message-pickup": "Du får ett meddelande när materialet finns att hämta på",
        "message-no-pickup": "Du får ett meddelande när materialet skickas från biblioteket.",
        "pickup-info-name": "Biblioteket kommer lägga materialet på en öppen avhämtningshylla med ditt namn synligt. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> om du istället vill hämta dina beställningar i informationsdisken.",
        "pickup-info-code": "I meddelandet (som kommer till din e-post och/eller SMS) finns en kod för avhämtning som du behöver för att hitta materialet på bibliotekets hylla för beställda böcker.",
        "my-loans-link-text": "Du kan se dina lån och beställningar i Mina lån."
      },
      "summary": {
        "copy-number": "Exemplar",
        "loantype": "Typ av lån",
        "pickup-location": "Hämta på",
        "reserve-notes": "Kommentar",
        "subscription-notes": "Detaljer",
        "goback-button": "Tillbaka",
        "submit-order-button": "Beställ",
        "submitting-order-button": "Skickar..."
      },
      "warning": {
        "message": "Du kan beställa det här materialet, men kommer inte kunna låna det, eftersom du har förseningsavgifter eller försenade lån.",
        "myloan-message": "<a class=\"alert-link\" href=\"https://minalan.ub.gu.se/\">Logga in i Mina lån</a> för att se vad du behöver göra."
      },
    },
    "login": {
      "login-heading": "Logga in med GU-konto",
      "login-body": "För studenter och anställda vid GU med ett gus-konto eller x-konto.",
      "header": "Logga in",
      "login-account-heading": "Logga in med bibliotekskonto",
      "login-account-body": "För användare som inte har något GU-konto.",
      "card-number-label": "Nummer på bibliotekskort",
      "card-number-label-extra-info": "Nummer på GU-kort eller bibliotekskort",
      "personal-number-label": "Personnummer",
      "pin-code-label": "PIN-kod",
      "pin-code-forgot-link-text": "Glömt din PIN-kod?",
      "pin-code-forgot-info-text-header": "Har du glömt din PIN-kod?",
      "pin-code-forgot-info-text-body1": "Om du är student eller medarbetare vid Göteborgs universitet byter du din PIN-kod i GU-kortportalen:<br/>gukort.it.gu.se",
      "pin-code-forgot-info-text-body2": "Byt din PIN-kod i Mina lån om du inte är student eller medarbetare vid Göteborgs universitet:<br/>minalan.ub.gu.se",
      "login-button": "Logga in",
      "library-card-link-text": "Skaffa bibliotekskonto",
      "username-password-error": "Fel användarnamn eller lösenord. Vänligen försök igen.",
      "oauth2-error": "Inloggningen avbröts. Vänligen försök igen.",
      "or": "Eller"
    }
  },
  "status-errors": {
    "404": "Vi hittade tyvärr inte posten du sökte.",
  },
  "login": {
    "casLogin": "Logga in"
  },
  "request-errors": {
    "header": "Det går inte att beställa",
    "NO_ID": {
      "message": "Sök efter något att beställa på <a href=\"http://www.ub.gu.se/\">bibliotekets webbplats.</a>",
    },
    "RESTRICTION_AV": {
      "message": "Du är avstängd från bibliotekets tjänster. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> om du har frågor om detta."
    },
    "RESTRICTION_ORI": {
      "message": "Du får inte låna eller beställa. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "CAN_NOT_BE_BORROWED": {
      "message": "Du kan inte beställa det här materialet själv. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
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
      "message": "Du är inte registrerad för att få låna på biblioteket. <a href=\"http://www.ub.gu.se/lana/kort/\">Ansök om ett bibliotekskort</a> för att komma igång."
    },
    "BROWSER_ERROR": {
      "message": "Något gick fel. Försök med en annan webbläsare, eller <a href=\"http://www.ub.gu.se/kontakta/\">kontakta biblioteket</a> för att få hjälp."
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
      "message": "Du har för många reservationer för att få beställa."
    },
    "NOT_RESERVABLE": {
      "message": "Materialet kan inte beställas. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "CANNOT_RESERVE_FROM_OTHER_BRANCHES": {
      "message": "Materialet kan inte beställas till andra bibliotek."
    },
    "TOO_MANY_HOLDS_FOR_THIS_RECORD": {
      "message": "Det gick inte att beställa det här materialet. <a href=\"http://www.ub.gu.se/kontakta/\">Kontakta biblioteket</a> för att få hjälp."
    },
    "BORROWER_NOT_FOUND": {
      "message": "Du är inte registrerad för att få låna på biblioteket. <a href=\"http://www.ub.gu.se/lana/kort/\">Ansök om ett bibliotekskort</a> för att komma igång."
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
