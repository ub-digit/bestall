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
      "content": '© <a title="University of Gothenburg" href="http://www.gu.se/">University of Gothenburg, Sweden</a><br>Box 100, S-405 30 Gothenburg<br>Phone +46 31-786 0000, <a title="Contact" href="http://www.gu.se/omuniversitetet/kontakt/">Contact</a>'
    },
  },
  "components": {
    "item-order-button": {
      "queue": "Reserve",
      "order": "Request",
      "collect": "Collect it from the shelf"
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
      "waiting": "Waiting for pick-up",
      "in_transit": "In transit",
      "delayed": "Overdue",
      "under_acquisition": "Ongoing purchase",
      "not_in_place": "Not on shelf",
      "unknown": "Unknown",
    },
    "pick-location": {
      "cannot-pickup-here": "can't be picked up here",
      "library-closed": "Closed"
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
        "items-are-available": "There are available items for you to request",
        "next-button": "Continue",
        "select-button": "Select",
        "order-subscription-button": "Request",
        "unspecified-holdings": "Unspecified holdings",
        "location": "Location",
        "note": "Holdings",
        "items": "Items",
        "subscriptions": "Holdings",
        "available": "Available",
        "not-available": "On loan",
        "currently-no-available-items": "Currently there are no available items.",
        "number-of-people-in-queue": "reservations for items on loan",
        "queue-up": "Make a reservation",
        "all-items-are-available": "All items are available.",
        "cant-be-ordered": "Can't be requested"
      },
      "details": {
        "header": "Your request",
        "loantype-dropdown-label": "Type of loan",
        "location-dropdown-label": "Pick up at",
        "next-button": "Continue",
        "cant-be-pickedup-here": "can't be picked up here",
        "not-allowed": "not allowed",
        "subscription-reserve-label": "Details about your request (mandatory)",
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
        "in-queue": "in the queue.",
        "message": "You will get a message when the request is available for pick-up at",
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
      },
      "warning": {
        "message": "You can place a request but you are not allowed to borrow anything, because of overdue loans or fines.",
        "myloan-message": "<a class=\"alert-link\" href=\"https://koha-staging.ub.gu.se/\">Log in to My loans</a> to find out what you need to do."
      },
    },
    "login": {
      "login-heading": "Log in with GU account",
      "login-body": "For students and employees at GU with a gus-account or an x-account.",
      "login-account-heading": "Log in with library account",
      "login-account-body": "For users without a GU account.",
      "card-number-label": "Library card number",
      "personal-number-label": "Personal identity number",
      "login-button": "Log in",
      "library-card-link-text": "Sign up for an account",
      "loginError": "Wrong username or password. Please try again.",
      "or": "Or"
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
    "RESTRICTION_AV": {
      "message": "You are suspended from using the library's services. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library if you have any questions concerning this.</a>"
    },
    "RESTRICTION_ORI": {
      "message": "You are not allowed to borrow or place requests. Please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library</a>."
    },
    "CAN_NOT_BE_BORROWED": {
      "message": "This material can't be requested or borrowed. For further assistance, please <a href=\"http://www.ub.gu.se/kontakta/\">contact the library</a>."
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
    "BROWSER_ERROR": {
      "message": "Something went wrong. Try another web browser, or <a href=\"http://www.ub.gu.se/kontakta/\">contact the library.</a>"
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