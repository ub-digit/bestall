export default {
  "home": {
    "title": "Order",
    "headers": {
      "logoPrintUrl": '/gu_logo_en_high.png',
      "level1": 'Gothenburg University Library',
      "level2": 'Request and reserve',
      "mainHeader": 'Request and reserve',
    },
    "footer": {
      "content": '© <a title="Göteborgs universitet" href="http://www.gu.se/">University of Gothenburg, Sweden</a><br>Box 100, S-405 30 Gothenburg<br>Phone +46 31-786 0000, <a title="Contact" href="http://www.gu.se/omuniversitetet/kontakt/">Contact</a>'
    },
  },
  "components": {
    "item-order-button": {
      "queue": "Reserve",
      "order": "Request"
    },
    "item-table": {
      "volume": "Item",
      "location": "Location",
      "status": "Status",
      "must_be_ordered": "Must be requested",
      "available": "Available",
      "not_for_home_loan": "Not for home loan",
      "reading_room_only": "Request to reading room",
      "loan_in_house_only": "Borrow on location",
      "loaned": "On loan until",
      "reserved": "Reserved",
      "waiting": "Waiting for pick up",
      "in_transit": "In transit",
      "delayed": "Overdue",
      "under_acquisition": "Ongoing purchase",
      "not_in_place": "Not on shelf",
      "unknown": "Unknown",
    },
    "pick-location": {
      "cannot-pickup-here": "can't be picked up here"
    },
    "pick-type-of-loans": {
      "not-allowed": "not allowed"
    },
    "progress-steps": {
      "step-items-label": "Items",
      "step-details-label": "Details",
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
      "header": "Your request",
      "items": {
        "next-button": "Continue",
        "select-button": "Select",
        "location": "Location",
        "note": "Note",
        "items": "Items",
        "subscriptions": "Holdings",
        "available": "Available",
        "not-available": "On loan",
        "currently-no-available-items": "Currently there are no available items.",
        "number-of-people-in-queue": "reservations for items on loan",
        "queue-up": "Make a reservation",
        "all-items-are-available": "All items are available."
      },
      "details": {
        "header": "Your request",
        "loantype-dropdown-label": "Select type of loan",
        "location-dropdown-label": "Select a pick up location",
        "next-button": "Continue",
        "cant-be-pickedup-here": "can't be picked up here",
        "not-allowed": "not allowed",
        "subscription-reserve-label": "Details about your request",
        "subscription-reserve-helptext": "Enter the requested item's volume, year, issue or page number.",
        "subscription-note": "You can make requests for items from these holdings:",
        "reserve-label": "Comment (optional)",
        "reserve-helptext": "Enter any additional details that you may have about your request.",
        "goback-button": "Go back"
      },
      "confirmation": {
        "header": "Thank you for your request!",
        "error-header": "The request couldn't be placed.",
        "you-have-place": "You have place",
        "in-queue": "in queue.",
        "message": "You will get a message when the request is available for pick up at",
        "my-loans-link-text": "See your loans and requests in My loans."
      },
      "summary": {
        "copy-number": "Item",
        "loantype": "Type of loan",
        "pickup-location": "Pick up at",
        "reserve-notes": "Comment",
        "subscription-notes": "Details",
        "goback-button": "Go back",
        "submit-order-button": "Request"
      }
    },
    "login": {
      "header": "Log in",
      "username-label": "Username:",
      "password-label": "Password:",
      "login-button": "Log in",
      "cas-link-text": "Log in using CAS"
    }
  },
  "status-errors": {
    "404": "The record you were looking for does not exist.",
  },
  "login": {
    "casLogin": "Log in"
  },
  "request-errors": {
    "header": "A request can't be placed.",
    "NO_ID": {
      "message": "Search for something to request at the <a href=\"http://www.ub.gu.se/\">library's website.</a>",
    },
    "BANNED": {
      "message": "You are suspended from using the library's services. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "CARD_LOST": {
      "message": "Your library account is suspended. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "FINES": {
      "message": "Your late fees are too high. Please visit one of <a href=\"http://www.ub.gu.se/bibliotek/\">the libraries</a> to pay your fee. We only accept card payment."
    },
    "DEBARRED": {
      "message": "You are not allowed to place a request. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "NO_ADDRESS": {
      "message": "We don't have your address on file. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library</a> to update your contact information."
    },
    "EXPIRED": {
      "message": "Your library account has expired. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library</a> to update your account."
    },
    "CAN_NOT_BE_BORROWED": {
      "message": "This material can't be requested or borrowed. You can collect the book from the shelf and read it in the library."
    },
    "ITEM_NOT_FOUND": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "ALREADY_BORROWED": {
      "message": "You have already borrowed this material."
    },
    "ALREADY_RESERVED": {
      "message": "You have already requested this material."
    },
    "NOT_FOUND": {
      "message": "You are not yet registered to borrow at the library. <a href=\"http://www.ub.gu.se/lana/kort/\">Apply for a library card</a> to get started."
    },
    "UNKNOWN_ERROR": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    }
  },
  "confirmation-errors": {
    "header": "A request can't be placed",
    "DAMAGED": {
      "message": "This material is damaged and can't be requested. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library</a> if you need any assistance."
    },
    "AGE_RESTRICTED": {
      "message": "You are not allowed to request this material. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library</a> if you need any assistance."
    },
    "ITEM_ALREADY_ON_HOLD": {
      "message": "You have already requested this material."
    },
    "TOO_MANY_RESERVES": {
      "message": "You have reached the maximum amount of allowed requests and can't place any more requests."
    },
    "NOT_RESERVABLE": {
      "message": "This material can't be requested. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library</a> if you need any assistance."
    },
    "CANNOT_RESERVE_FROM_OTHER_BRANCHES": {
      "message": "This material can't be requested to other libraries."
    },
    "TOO_MANY_HOLDS_FOR_THIS_RECORD": {
      "message": "This material can't be requested. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library</a> if you need any assistance."
    },
    "BORROWER_NOT_FOUND": {
      "message": "You are not yet registered to borrow at the library. <a href=\"http://www.ub.gu.se/lana/kort/\">Apply for a library card</a> to get started."
    },
    "BRANCH_CODE_MISSING": {
      "message": "You have to choose what library you want as your pick-up location."
    },
    "ITEMNUMBER_OR_BIBLIONUMBER_IS_MISSING": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "BIBLIONUMBER_IS_MISSING": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "ITEM_DOES_NOT_BELONG_TO_BIBLIO": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "UNRECOGNIZED_ERROR": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "MISSING_USER": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "MISSING_LOCATION": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "MISSING_BIBLIO": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    },
    "MISSING_LOAN_TYPE": {
      "message": "Something went wrong. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
    }
  }
};