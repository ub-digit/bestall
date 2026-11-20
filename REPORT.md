# Bestall — Full Codebase Review Report

**Scope:** entire repository at `/work` — Rails 7.2.1 API backend, Nuxt 4 (Vue 3) SSR frontend, Docker Compose stack, Ansible deployment, specs, docs.
**Method:** static reading of every source, config, spec, template and deployment file. Nothing was executed; the application was not modified.
**Date of review:** repository state as found in the working tree (Rails 7.2.1 / `compatibilityDate: 2025-07-15`, host vars referencing `release-2026.*`).

Severity legend: **Critical** → exploitable/data-leaking/broken in normal operation · **High** → likely bug or serious exposure · **Medium** → real defect, limited blast radius · **Low** → hygiene/maintainability.

---

## 1. Executive summary

| #   | Area                     | Count | Highlights                                                                                                                                                               |
| --- | ------------------------ | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | Security & privacy       | 18    | Header-based identity trust, `CORS origins '*'`, client-supplied authorization data, PII logging, unauthenticated file share with directory indexes, credentials in URLs |
| 2   | Backend correctness      | 22    | Cached objects mutated per request, `force=false` string bypasses authorization, silent "success" on failed orders, `nil` crashes, 6 `pp` debug dumps                    |
| 3   | Backend architecture     | 12    | No DB, models are HTTP-scrapers, no timeouts/caching/parallelism, business rules duplicated in client                                                                    |
| 4   | Frontend correctness     | 20    | Dead filter code that silently disables loan-type restrictions, `Object.assign` on arrays, unreachable branches, broken import paths, unguarded `error.response.status`  |
| 5   | Frontend architecture    | 9     | Duplicated error-code tables, `ssr:false` + server proxies, no lint/typecheck/test tooling                                                                               |
| 6   | API contract             | 8     | `is_availible` typo, camelCase/snake_case mix, `Location` TS type does not match payload                                                                                 |
| 7   | i18n & a11y              | 7     | Missing keys, `v-html` + `escapeHtml:false`, `lang="en"` on Swedish pages                                                                                                |
| 8   | Dependencies             | 10    | `rspec-rails 3.9` on Rails 7.2, Puma 3.12, Prawn 1.3, deprecated `rest-client`, unused gems                                                                              |
| 9   | Rails config & dead code | 14    | `ENVIRONMENT=production` for dev/lab, dead `app/views`, `app/assets`, helpers, mailer, `secrets.yml`, Rails-5 initializers                                               |
| 10  | Tests                    | 8     | Suite almost certainly cannot boot; specs reference non-existent models/controllers                                                                                      |
| 11  | Deployment               | 13    | Ubuntu 14.04 Apache image, broken Compose variable names, Apache proxies `/api/reserve` (route is `/api/reserves`), `localhost` proxying inside a bridge network         |
| 12  | Documentation            | 5     | README instructs `bower install` and `rake db:migrate` in a DB-less app                                                                                                  |

The most consequential single finding is **SEC-01 / BE-02**: the backend trusts an unauthenticated `current-username` HTTP header and trusts client-supplied user attributes, so the whole "who may order what" model is enforced by the browser rather than the server.

---

## 2. Security & privacy

### SEC-01 — Identity is taken from an unauthenticated request header (Critical)

**Where:** `app/controllers/application_controller.rb:57-63`, used by every API controller (`validate_access`, `validate_access_or_apikey`), plus `app/controllers/api/biblios_controller.rb:9`, `app/controllers/api/users_controller.rb:2`.

```ruby
def validate_token
  return true if @current_username
  current_user_from_header = request.headers['current-username']
  @current_username = User.find_by_username(current_user_from_header).try(:username)
  return true if @current_username
end
```

**Problem.** There is no token, signature, cookie or shared secret binding the request to the asserted user. Any client that can reach the backend (the Apache vhost `bestall-server.conf.j2` exposes the whole API over HTTPS, and Compose publishes the Rails port) can send `current-username: <any cardnumber or personal number>` and then:

- read that patron's full record — name, category, fines, loans, reserves, generated _pickup code_ (`Api::UsersController#current_user` → `User#as_json`);
- create holds **as that patron** (`Api::ReservesController#create` uses `cardnumber: @current_username`);
- generate print slips containing their PII (`Api::PrintController` is api-key protected, but `Api::ReservesController` also reaches `Print` through the same header path).

The comment in the code ("_can be userid, cardnumber or personalnumber, we need to always set current_username to username_") shows the header is intended to carry a patron identifier directly, i.e. this is by design, not an accident. The design is unsound: the frontend is the only thing asserting identity.

**Suggestion.** Introduce a real session token:

1. On sign-in, the frontend's auth handler asks the backend to mint a short-lived signed token (JWT — the `jwt` gem is already in the `Gemfile` but unused — or an opaque token stored server-side) bound to the cardnumber.
2. `validate_token` verifies signature + expiry and derives `@current_username` **only** from the verified token, never from a raw identity header.
3. Keep the `current-username` header only as a _non-authoritative hint_ (e.g. for cache keys/logging) and remove it from all authorization paths.
4. Until that is done, at minimum require a shared service secret header on every internal call and restrict the backend vhost to the frontend container network.

### SEC-02 — CORS allows any origin with any header (Critical)

**Where:** `config/initializers/cors.rb:8-13`

```ruby
origins '*'
resource '*', headers: :any, methods: [:get, :post, :patch, :put]
```

**Problem.** Combined with SEC-01 this means _any website in any browser_ can call the API with an arbitrary `current-username` header and read/modify patron data. `headers: :any` explicitly whitelists the custom identity header. Because the API needs no cookies, the Same-Origin Policy provides no protection.

**Suggestion.** Restrict `origins` to the deployed frontend hostnames (`FRONTEND_HOSTNAME`/`BACKEND_HOSTNAME` are already available as env vars), restrict `headers:` to the exact set actually used (`content-type`, and the identity header only while it still exists), and remove `:patch/:put` (no such routes exist in `config/routes.rb`).

### SEC-03 — Authorization-relevant data is supplied by the client (Critical)

**Where:** `app/controllers/api/loan_types_controller.rb:29-38`, `app/controllers/api/pickup_locations_controller.rb:43-52`, `app/models/loan_type.rb:31-56`, `app/models/location.rb:39-98`, `app/controllers/api/reserves_controller.rb:56-62`.

**Problem.** `LoanType.where(category_code:, item_type:, status_limitation:, attr_orderpermission:)` and `Location.where(current_user:, current_item:, current_subscription:)` decide which loan types and pickup libraries a user may use, but every input comes from the request body/query. Consequences:

- Send `current_user: {categorycode: "SD"}` → the "Skicka materialet till mig" (send-to-me, loan type 5) option appears for a user who is not entitled to it.
- Omit `current_item.status_limitation` → home-loan options stay enabled for reference-only / monitored-reading-room material.
- `reserves_controller.rb:56-62` derives the delivery branch from `orderToSubmit[:current_item_extended][:location_id]`, which the client also controls.

The frontend even documents this as intentional (`server/api/loantypes.ts:18`, `locations.ts:25` comments say the query parameter is a "fallback"), but the backend never re-validates anything at write time.

**Suggestion.** Treat all order-eligibility inputs as _presentation hints only_. In `Api::ReservesController#create`, re-fetch the user (`User.get_category_code(@current_username)`) and the item (`Biblio.find_by_id(...).items.find { … }`) server-side and reject the order if the requested loan type / pickup branch is not permitted for that real user and real item. Remove the client-supplied `current_user` object entirely from these endpoints.

### SEC-04 — `force` parameter silently disables the "can be borrowed" check (Critical)

**Where:** `app/controllers/api/biblios_controller.rb:8`, `frontend/server/api/biblios/[id].ts:20-21,118`.

```ruby
if biblio.can_be_borrowed || biblio.redirect_url || params[:force]
```

```ts
let { force } = getQuery(event) as { force?: boolean };
force = force ?? false;
… `/biblios/${id}?items_on_subscriptions=true&force=${force}`
```

**Problem.** The frontend always appends `force=false`, which arrives at Rails as the **String** `"false"`, which is **truthy** in Ruby. The `can_be_borrowed` restriction (`FORBIDDEN` / `CAN_NOT_BE_BORROWED`) is therefore never triggered in production, and any caller can also pass `?force=1` explicitly.

**Suggestion.** Use an explicit comparison: `params[:force].to_s == "true"` (or `ActiveModel::Type::Boolean.new.cast(params[:force])`), and prefer a server-side policy over a client-supplied override flag. Add a regression spec.

### SEC-05 — Unauthenticated proxy leaks any patron's data by IDOR (High)

**Where:** `frontend/server/api/currentuser.get.ts:9-25`, called from `frontend/app/pages/order/[id]/index.vue:27-29`.

The route requires a session (`getServerSession`) but then forwards `current_username` **taken from the query string** as the backend's identity header:

```ts
let { biblio, current_username } = getQuery(event) …
headers: { "current-username": current_username || "" }
```

Any logged-in user can call `/api/currentuser?current_username=<someone else's cardnumber>` and receive that person's name, category, fines, loan list, reserve list and pickup code.

**Suggestion.** Always use `session.user.cardnumber` for the header (as the other routes correctly do) and drop the query parameter. Add a test asserting a mismatched `current_username` is ignored.

### SEC-06 — Patron PDFs are served unauthenticated with directory listings (High)

**Where:** `ansible/templates/bestall-apache.conf.j2:1-10`, `ansible/templates/sites/bestall.conf.j2:10-27`, `app/models/print.rb:181-190`.

The generated slips (name, first name, cardnumber, borrowernumber, category, pickup code, barcode) are written to `/opt/bestall-files` and published by Apache:

```apache
Alias /files /var/www/bestall/files
<Directory /var/www/bestall/files>
    Require all granted
    AllowOverride all
    Options -MultiViews +Indexes
</Directory>
```

This `*:80` vhost has **no authentication** and enables **`+Indexes`**. The HTTPS vhost does protect `/files` with Basic auth, but the plain-HTTP vhost above grants `Require all granted`; a request that does not match any `ServerName` (direct IP access, port 80) reaches it. Filenames are guessable-ish (`<sublocation>_pr<location>_<YYYYMMDDHHMMSS>_<32-hex>.pdf`), and the index listing removes even that obstacle.

**Suggestion.** Remove `+Indexes`, require authentication on _every_ vhost that serves `/files`, disable plain-HTTP serving of the files share entirely (redirect-only vhost with no `Alias`), set `AllowOverride None`, and consider short-lived signed URLs instead of a static directory. Also set explicit ownership/mode when the Ansible role copies `.htpasswd`.

### SEC-07 — Path traversal in the print filename (High)

**Where:** `app/models/print.rb:185-188`.

```ruby
suffix = "_#{obj[:reserve_id]}" if obj[:reserve_id]
filename = "#{sublocation_id}_pr#{location_id}_#{Time.now…}_#{SecureRandom.hex}#{suffix}.pdf"
pdf.render_file "#{file_path}/#{filename}"
```

`reserve_id` comes straight from the API parameter (`app/controllers/api/print_controller.rb:41`) with no validation. `reserve_id=../../../../tmp/x` writes outside `file_path` (the `.pdf` suffix limits but does not prevent abuse, e.g. overwriting arbitrary `*.pdf`, or writing into app directories that are later served/loaded).

**Suggestion.** Whitelist `reserve_id` (`\A\d+\z`) at the controller boundary, and build the path with `File.join(File.expand_path(file_path), File.basename(filename))`, verifying the result stays inside the base directory.

### SEC-08 — XML injection / encoding crash in the Libris proxy (High)

**Where:** `app/controllers/api/libris_controller.rb:23-45`.

```ruby
"<request><biblio_id>#{librisid}</biblio_id>…".encode("ISO-8859-1")
```

- `librisid` is interpolated into XML without escaping → an attacker-controlled `sigel` can inject arbitrary XML nodes into the upstream Libris request (XXE-style / request smuggling depending on the upstream parser).
- `.encode("ISO-8859-1")` raises `Encoding::UndefinedConversionError` for any non-Latin-1 character (the code itself has a `fix_diacritics` helper, which shows the problem is real) → unhandled 500.
- The endpoint has no authentication and no rate limiting, and it proxies to an external service on behalf of callers → an SSRF-ish amplification surface.

**Suggestion.** Build the request with a builder (`Nokogiri::XML::Builder`) and escape all input; send UTF-8 unless the contract proves otherwise; require the same API key used elsewhere; add a per-IP rate limit.

### SEC-09 — PII written to logs in many places (High)

**Backend (`pp` dumps to stdout, captured by `RAILS_LOG_TO_STDOUT=1`):**

- `app/controllers/api/reserves_controller.rb:5` — `pp params` dumps the _entire_ order payload: cardnumber, user data, hold notes.
- `app/controllers/api/loan_types_controller.rb:32`, `pickup_locations_controller.rb:51`, `app/models/reserve.rb:83` (`pp obj` — a full `Reserve` incl. borrowernumber and notes), `reserve.rb:127` (`pp location`), `app/models/biblio.rb:286` (`pp @origin`).

**Frontend (Nitro server logs):**

- `server/api/loantypes.ts:19`, `locations.ts:26`, `biblios/[id].ts:28-30`, `order/[id].post.ts:49`, `auth/[...].ts:90`, `contact.post.ts:3,23`, `auth/[...].ts:32,135-138,144-146,152`.

**Also:** `config/environments/lab.rb` and `staging.rb` set `config.log_level = :debug`, which additionally logs request parameters.

**Suggestion.** Delete all `pp`/`console.log` of payloads (or gate them behind an explicit debug flag that is off by default), extend `config/initializers/filter_parameter_logging.rb` (currently only `password`) with `:api_key, :token, :current_username, :cardnumber, :borrowernumber, :pin, :username, :reservenotes`, and set lab/staging log level to `:info`.

### SEC-10 — Service credentials and patron identifiers sent in URL query strings (High)

**Where:** `app/models/location.rb:31`, `sublocation.rb:25`, `biblio.rb:154,165,169`, `user.rb:33,47`, `reserve.rb:73-75`.

Every Koha call embeds `login_userid=…&login_password=…` (and for `User.authenticate`, the patron's `cardnumber` and `pin`; for `Reserve.add`, the cardnumber and hold notes) in the **query string of a GET request**. Query strings are logged by the Koha server, any intermediate proxy, and by `RestClient` on error. `Reserve.add` also performs a _state-changing_ operation with GET, which is cacheable/replayable by intermediaries.

**Suggestion.** Use HTTP Basic auth headers (or a token) instead of query parameters, use POST for writes, and never put PINs in URLs. This is a Koha-contract change, so coordinate it; in the meantime ensure no proxy logs query strings for the Koha host.

### SEC-11 — `users/authenticate` is a GET endpoint with no throttling (High)

**Where:** `config/routes.rb:18`, `app/controllers/api/users_controller.rb:5-9`, `frontend/server/api/auth/[...].ts:199-213`.

`GET /api/users/authenticate?username=…&password=…` has no `before_action` authentication, no rate limit, no lockout, and is reachable both from the frontend proxy and directly through the backend vhost. Credentials are additionally URL-encoded by hand (`?username=${credentials.username}&password=${credentials.password}`) so a password containing `&`, `#` or `=` silently alters the request.

**Suggestion.** Make it POST, encode the body properly, add throttling/backoff (rack-attack or a simple counter), and log failed attempts with a non-PII key.

### SEC-12 — XSS-capable rendering of translated strings (High)

**Where:** `frontend/nuxt.config.ts:93-96` (`strictMessage: false`, `escapeHtml: false` with the comment `// how to make it secure ask Stefan`), `frontend/app/pages/order/[id]/confirm.vue:17-21,29-34`, `components/Footer.vue:41`, `components/AuthStatus.vue:21`, `components/view/book.vue:64`.

With `escapeHtml: false`, vue-i18n does **not** escape interpolated values, and the templates then inject the result with `v-html`. The interpolated values include backend data (pickup library name, queue position) that ultimately originates in Koha (branch names, sublocation names). Any Koha-side value containing markup becomes executable HTML in a patron's browser.

**Suggestion.** Set `escapeHtml: true`, keep `strictMessage: false` only where literal markup is required, and replace `v-html` with `<i18n-t>` components (already used elsewhere, e.g. `error.vue:137`) which handle interpolation safely.

### SEC-13 — Open redirect through backend-supplied `redirect_url` (Medium)

**Where:** `frontend/app/error.vue:80` (`window.location.href = biblio.value.redirect_url`), `frontend/server/api/verifyMaterial/[id].ts:10-12`, `app/models/biblio.rb:57-66` (URL taken from MARC 856/link fields).

The redirect target is catalog data. If a record's link field is wrong or malicious, users are sent off-site from a trusted GU domain (phishing vector), and the URL is also rendered as a link (`error.vue:102`).

**Suggestion.** Validate the redirect host against an allow-list (`bibliotekskort-*`, `minalan-*`, `www.ub.gu.se`, known URN resolvers) both in `Biblio#redirect_url` and in the frontend before navigating.

### SEC-14 — Cache-clear endpoint: crash + weak secret handling (Medium)

**Where:** `app/controllers/api/cache_controller.rb:2-10`.

`APP_CONFIG['cache']['api_key']` raises `NoMethodError` when the `cache:` key is absent (it is absent in `config/config_secret.test.yml`), and the key is compared from a **query parameter** (`GET /api/cache/clear?api_key=…`), so the secret lands in access logs. The endpoint is also proxied publicly (`ansible/templates/sites/bestall.conf.j2:44-45`).

**Suggestion.** Use `APP_CONFIG.dig('cache','api_key')`, compare with `ActiveSupport::SecurityUtils.secure_compare`, accept the key via a header, and restrict the route to internal callers.

### SEC-15 — Hard-coded OAuth client credentials in source (Medium)

**Where:** `frontend/server/api/auth/[...].ts:28-29` (`clientId: "bestall-local"`, `clientSecret: "bestall-local-secret"`).

The local mock-OIDC provider is enabled whenever `localOAuthIssuer` is set, and its secret is committed. A dev-only auth path with a publicly known secret must never be reachable in production.

**Suggestion.** Move to an env var, and additionally gate the provider on a non-production environment flag so a mis-set `NUXT_LOCAL_OAUTH_ISSUER` cannot open a password-less login in production.

### SEC-16 — Secrets and environment material committed to the repository (Medium)

**Where:** `config/secrets.yml` (literal `secret_key_base` values for development and test), `docker/.env` (GitHub OAuth client ID, internal hostnames, printer IPs, lab URLs), `config/config_secret.yml` (committed ERB template — acceptable, but it is _not_ ignored while `docker/.gitignore` only ignores `secrets.env`), `ansible/**/vault.yml` (encrypted, but the vault password file path and the encrypted files live together in the repo).

**Suggestion.** Remove `config/secrets.yml` entirely (Rails 7 uses `credentials`/`SECRET_KEY_BASE`), add `docker/.env` to `.gitignore` and provide `docker/.env.example`, and rotate the GitHub client secret if it is considered sensitive.

### SEC-17 — Ansible roles are pinned to moving references (Medium)

**Where:** `ansible/requirements.yml` (roles installed from `master`/unpinned), `ansible/README.md` ("run the same command with `-f` to force reinstallation").

Deployment behaviour can change without any commit in this repository, and there is no supply-chain pinning of the role that writes Apache configs, `.htpasswd` and secrets.

**Suggestion.** Pin `version:` to tags/commit SHAs and commit `requirements.lock`-style pinning.

### SEC-18 — Session/JWT handling in the frontend (Medium)

**Where:** `frontend/server/api/auth/[...].ts:164` (`secret: runtimeConfig.apiSecret` — empty string default in `nuxt.config.ts:4`), `:87-122` (`session` callback returns `null` on any backend hiccup), `:124-161` (`jwt` callback).

If `NUXT_API_SECRET` is unset, next-auth falls back to an unpredictable/absent secret (sessions break or, depending on version, are signed with a dev default). Returning `null` from the `session` callback on a transient backend failure silently logs every user out.

**Suggestion.** Fail fast at boot when `apiSecret` is empty; on user-data fetch failure keep the session but mark it degraded (the frontend already has a `UserWarning` component for this).

---

## 3. Backend correctness bugs

### BE-01 — `Location.all` is cached, then mutated by every request (Critical)

**Where:** `app/models/location.rb:26-37` (cache) and `:47-96` (mutation).

`Location.all` returns the _same object instances_ stored in `Rails.cache` for 24 hours. `Location.where` then mutates them in place:

```ruby
location.is_disabled = true
location.name_sv += " (stängt)"
location.name_en += " (can't be picked up here)"
```

Consequences:

- Once one user's order disables a pickup location, **every subsequent user for up to 24 h** sees that location as disabled, with the wrong reason.
- The suffixes accumulate: after several filtered requests the name becomes `"Göteborgs Universitetsbibliotek (kan ej beställas hit) (kan ej beställas hit) (stängt)"`.
- The state is per-process (Puma workers each have their own copy), so behaviour differs between workers and after restarts — a classic heisenbug.

**Suggestion.** Never mutate cached models. Have `Location.where` return lightweight _view objects_ (`location.dup` at minimum, ideally a separate `PickupLocationView` struct) computed from the immutable cached data. Add a spec that calls `where` twice with different inputs and asserts the second result is unaffected.

### BE-02 — Silent success when a hold cannot be created (Critical)

**Where:** `app/controllers/api/reserves_controller.rb:100-125`, `app/models/reserve.rb:49-92`.

`Reserve.add` returns `{code:, msg:, errors:}` on failure, and the controller only maps codes **400, 403, 404, 500**. For any other outcome — Koha returning 401/422/503, or the blanket `rescue => error` at `reserve.rb:90-92` producing `code: nil` (network error, `error.response` is `nil`) — **no error is written to `@response[:errors]`**, so `render_json` renders `@response` with HTTP 200 and an empty body. The frontend (`server/api/order/[id].post.ts:64-76`) then reads `data.reserve` (undefined) and either throws a `TypeError` or shows the confirmation page. A patron can be told "your order is registered" when nothing was created.

**Suggestion.** Invert the logic: build a success object explicitly, and treat _everything else_ as an error (`error_msg(ErrorCodes::INTERNAL_SERVER_ERROR, …)` in an `else` branch). In `Reserve.add`, distinguish "HTTP error with a body" from "transport failure" and never return `{code: nil}`.

### BE-03 — `Reserve.parse_error` crashes on responses without `error_code` (High)

**Where:** `app/models/reserve.rb:94-103` and `:29-46`.

```ruby
if xml.search('//response/error_code').text.present?
  error_code = xml.search('//response/error_code').text
end
[{code: Reserve.error_code(error_code), …}]
```

`error_code` is `nil` when the element is missing (typical for Koha/CGI errors), and `Reserve.error_code` immediately calls `koha_code.underscore` → `NoMethodError` inside the error handler. Similarly `Nokogiri::XML(nil)` raises when the exception has no response body. The failure path therefore often turns into a 500 instead of a proper error message.

**Suggestion.** Default `error_code = nil` explicitly, return `UNRECOGNIZED_ERROR` for `nil`, and guard `parse_error(nil)` by returning a generic error list.

### BE-04 — `NoMethodError` on unknown loan type (High)

**Where:** `app/controllers/api/reserves_controller.rb:9`.

```ruby
if loantype.present? && LoanType.find_by_id(loantype.to_i).send_material?
```

`LoanType.find_by_id` returns `nil` for any id not in the hard-coded list (`app/models/loan_type.rb:60-68`) → `nil.send_material?` → 500. Note the same file at line 69-74 _does_ nil-guard, so the omission at line 9 is inconsistent.

**Suggestion.** `loan_type_obj = LoanType.find_by_id(loantype.to_i)` once, validate it early and return `UNPROCESSABLE_ENTITY`/`MISSING_LOAN_TYPE` when nil.

### BE-05 — `NoMethodError` when `fullBiblio` is absent (High)

**Where:** `app/controllers/api/reserves_controller.rb:53` and `:60`.

```ruby
has_item_level_queue = params[:orderToSubmit][:fullBiblio][:has_item_level_queue] ? … : false
…
branchcode = params[:orderToSubmit][:fullBiblio][:default_queue_location]
```

For orders submitted by Koha (the subscription path explicitly documents "when fullBiblio is not present") or any client that omits `fullBiblio`, `params[…][:fullBiblio]` is `nil` → 500. The guard at line 27-28 (`params[:orderToSubmit][:fullBiblio] ||= {}`) only runs inside the subscription branch.

**Suggestion.** Use `params.dig(:orderToSubmit, :fullBiblio, :has_item_level_queue)` and `… .fetch(:default_queue_location, nil)`, and validate the payload shape up front.

### BE-06 — `Biblio.queue_level` crashes for record types outside the table (High)

**Where:** `app/models/biblio.rb:49-55`, called from `has_item_level_queue` (`:38-43`).

`RECORD_TYPES` covers 7 MARC leader codes. `parse_record_type` can produce other labels (e.g. component parts, resources not in the list), in which case `type_obj` is `nil` and `type_obj[:queue_level]` raises. Because `Biblio.find_by_id` wraps everything in a blanket `rescue` (`:177-184`), this surfaces as a mysterious **404 "Item not found"** rather than a bug.

**Suggestion.** `RECORD_TYPES.find { … }&.dig(:queue_level) || 'bib'` plus a logged warning, and add the missing leader codes to the table.

### BE-07 — `Item#lost?` treats a missing `itemlost` field as "lost" (High)

**Where:** `app/models/item.rb:101-103` (`@lost != '0'`), `parse_rawdata` at `:176-177` sets `@lost = nil` when the field is absent.

Koha's items service omits `itemlost` for normal items in some responses. `nil != '0'` → `true` → the item is considered lost, which makes `can_be_ordered` return false (`item.rb:57` `return false if lost?`) and `masked?`/`not_in_place?` logic inconsistent. Items silently become unorderable.

**Suggestion.** Normalise in `parse_rawdata` (`@lost = rawdata["itemlost"].to_s.presence || '0'`) and express predicates against an explicit set: `LOST_CODES = %w[1 2 3 5 6]`.

### BE-08 — `Item#in_transit?` compares incompatible identifiers (High)

**Where:** `app/models/item.rb:145-147`.

```ruby
@in_transit == '1' || (@currentlocation_id != @location_id)
```

`@currentlocation_id` is Koha's `holdingbranch` (a branch code), while `@location_id` is derived in `Item#initialize` from the **sublocation id prefix** (`sublocation.rb:12` `@location_id = id[0..1]`). When `holdingbranch` is missing, `nil != "40"` → the item is reported `IN_TRANSIT`, and `is_availible` returns false. Even when present, the comparison only works because branch codes and location ids happen to coincide.

**Suggestion.** Compare like-for-like (`holdingbranch` vs `Location#pickup_location_id`/branch code), treat `nil` as "unknown, not in transit", and add unit tests with sparse item payloads.

### BE-09 — `Item#status` raises on malformed dates (Medium)

**Where:** `app/models/item.rb:158-166`.

`Date.parse(@due_date)` is called twice with no rescue; any non-ISO or garbage `datedue` from Koha raises `ArgumentError` and 500s the whole biblio page.

**Suggestion.** `begin Date.parse(…) rescue nil end` in a small helper, and treat unparseable dates as "no due date".

### BE-10 — `Sublocation` boolean fields are strings, with a broken fallback (High)

**Where:** `app/models/sublocation.rb:56-62`.

```ruby
is_open_loc = loc.xpath('open_loc').text          # "" when absent
…
is_open_loc: (is_open_loc || is_open_pickup_loc)  # "" is truthy → fallback never applies
```

- `""` is truthy in Ruby, so the intended fallback to `open_pickup_loc` is dead code.
- The values are strings (`"1"`, `"0"`, `""`), and consumers compare with `== '1'` (`item.rb:89-99`) while the frontend `Location` TS type declares them as `string` and other code treats them as booleans.

**Suggestion.** Normalise to real booleans at parse time (`%w[1 true].include?(text.strip.downcase)`), and keep the string form only if the API contract requires it.

### BE-11 — `Sublocation#location_id` derived by string slicing (Medium)

**Where:** `app/models/sublocation.rb:12` (`@location_id = id[0..1]`).

This silently assumes every sublocation id starts with a two-character location code. Location ids ≥ 100, or sublocation codes that are not prefixed, produce wrong locations (and `find_all_by_location_id` then returns the wrong set).

**Suggestion.** Store the mapping explicitly (the `config/data/locations.json` file already models locations) or parse with a documented pattern and raise on non-conforming ids.

### BE-12 — Dummy fallback objects hide lookup failures (Medium)

**Where:** `app/models/location.rb:104-110`, `sublocation.rb:31-37`.

```ruby
return self.new(id: "1", name_sv: "", name_en: "", …) if res.blank?
```

An unknown location/sublocation silently becomes a fake record with id `"1"` and empty names. `reserves_controller.rb:15-17` then writes empty pickup-location names into the order response and the printed slip; `Item#initialize` silently attributes items to location `"1"`.

**Suggestion.** Return `nil` and let callers decide (404 / validation error), or raise a domain error. `LoanType.find_by_id` already returns `nil` — make the three lookups consistent.

### BE-13 — Sublocation English names are Swedish text (Medium)

**Where:** `app/models/sublocation.rb:53-54` (`name_sv` and `name_en` both read `lib_opac`); same pattern in `location.rb:126-127` for unconfigured locations.

English-locale users see Swedish sublocation names, and `frontend/server/api/biblios/[id].ts:35` faithfully localises to the Swedish string.

**Suggestion.** Source an English label (Koha `lib_opac` per-language, or add `name_en` to `config/data/locations.json` for every sublocation) and fall back to Swedish with a logged warning.

### BE-14 — `User.create_pickup_code` crashes on incomplete users (Medium)

**Where:** `app/models/user.rb:65-72`.

`obj[:cardnumber].split(…)` raises when `cardnumber` is nil; `obj[:categorycode]` nil produces `"()"`. `User#as_json` (`:9-13`) calls this on **every** serialization, so a patron record without a cardnumber 500s `users/current`.

**Suggestion.** Guard nils, and only compute the pickup code when it will actually be shown (it is also a privacy concern to always emit it).

### BE-15 — Denied-user error list is incomplete (Medium)

**Where:** `app/controllers/api/users_controller.rb:21-28`.

`restriction_fines` and `restriction_overdue` are computed and even used to decide `user.denied`, but only `RESTRICTION_AV` is pushed into `error_list`. A patron blocked by fines/overdues gets `FORBIDDEN` with an **empty** error list, and the frontend renders no explanation.

**Suggestion.** Push `RESTRICTION_FINES` / `RESTRICTION_OVERDUE` entries (the frontend `OrderDenied`/`error.vue` already look up `orderDenied.errors.<CODE>`), and add the matching i18n keys (see I18N-02).

### BE-16 — `has_borrowed_item?` / `has_reserved_item?` use `eql?` on mixed types (Medium)

**Where:** `app/models/user.rb:57-63`.

`loan[:biblionumber].eql? biblio_id` — `eql?` is type-strict (`"123".eql?(123) == false`). Depending on whether Koha returns strings and whether `params[:biblio]` arrives as a string, the "already borrowed / already reserved" check silently never fires, allowing duplicate orders.

**Suggestion.** Compare with `.to_s == biblio_id.to_s`.

### BE-17 — Blanket rescues convert bugs into 404s (High)

**Where:** `app/models/biblio.rb:177-184`, `app/models/user.rb:37-39`, `:53-55`, `app/models/reserve.rb:90-92`.

`rescue => error; return nil` (or `false`) swallows programming errors (`NoMethodError`, `ArgumentError`, XML/JSON parse failures) and reports them as "not found" or "authentication failed". This is why several bugs above are invisible, and it makes credential/network outages indistinguishable from "user does not exist" — a UX and security problem (see SEC-11 note on lockouts).

**Suggestion.** Rescue specific exception classes (`RestClient::NotFound`, `RestClient::Exception`, `Nokogiri::XML::SyntaxError`), log the rest with context, and let genuine bugs surface as 500s with an alert.

### BE-18 — `JSON.parse(...)["reserves"]` / `["items"]` unguarded (Medium)

**Where:** `app/models/biblio.rb:250-251`.

If Koha returns an unexpected shape, `reserves`/`item_list` is `nil` and the subsequent `.each`/`.length` raises — again masked by BE-17 into a 404.

**Suggestion.** `(JSON.parse(items_data)["items"] || [])` and validate the payload.

### BE-19 — `Item#as_json` serialises every instance variable (Medium)

**Where:** `app/models/item.rb:24-33`.

`ActiveModel::Serialization#attributes` is `instance_values`, so `super(except: ["found"])` emits _all_ ivars, including internal ones (`@has_item_level_queue`, `@biblio_id`, `@ccode`, `@stack`, `@public_notes`), while the declared `attr_accessor` list (`:4-8`) is out of sync with the ivars actually set (`@sublocation_name_sv`, `@location_name_en`, …). The API contract is therefore "whatever happens to be in memory", and the frontend `Item` type drifts.

**Suggestion.** Define an explicit `SERIALIZE_KEYS` list / `as_json` hash. This also lets the `is_availible` typo be fixed behind a compatibility alias (CT-01).

### BE-20 — `Reserve#as_json` returns patron PII to the client (Medium)

**Where:** `app/models/reserve.rb:3-4` + default serialization.

The order confirmation response includes `cardnumber`, `borrowernumber`, `reservenotes`, `branchcode`, timestamps — more than the confirmation page needs (`showQueuePosition`, `positionInQueue`, `pickupLocation_*`).

**Suggestion.** Explicit `as_json` limited to the fields in `OrderSuccessResponse`.

### BE-21 — `show_pickup_code` is truthy when unset (Medium)

**Where:** `config/config_secret.yml:14` (`show_pickup_code: <%= ENV["SHOW_PICKUP_CODE"] %>`), consumed at `app/models/print.rb:102,147`.

When the env var is unset, ERB renders an empty string, and `""` is truthy in Ruby → the pickup code block is printed on slips even when the feature is "off". The same ERB-empty-string trap applies to `api_key` (partially mitigated by blank checks) and `frontend_hostname`.

**Suggestion.** Compare explicitly (`%w[true 1 yes].include?(APP_CONFIG['show_pickup_code'].to_s)`), or coerce booleans in `load_config.rb`.

### BE-22 — Routes expose actions that do not exist (Medium)

**Where:** `config/routes.rb:4-6`.

- `resources :session` → `Api::SessionsController` **does not exist** (there is no `session_controller.rb` at all) → any request to `/api/session*` raises `AbstractController::ActionNotFound` (500).
- `resources :biblios` and `resources :reserves` generate index/create/update/destroy routes, but only `show` and `create` are implemented → same 500 behaviour instead of 404/405.

**Suggestion.** `resource :session, only: []` / `resources :biblios, only: :show` / `resources :reserves, only: :create`, and delete the dead `session` resource. Add a request spec that every route maps to an existing action.

### BE-23 — Debug statements left in production code (High)

Six `pp` calls (see SEC-09): `reserves_controller.rb:5`, `loan_types_controller.rb:32`, `pickup_locations_controller.rb:51`, `reserve.rb:83`, `reserve.rb:127`, `biblio.rb:286`.

**Suggestion.** Remove them; add a CI grep (`grep -rnE '^\s*pp ' app/`) as a cheap guard.

### BE-24 — Dead and misleading code in the controllers (Low)

- `app/controllers/application_controller.rb:66-74` `get_token` — never called anywhere.
- `app/controllers/application_controller.rb:2` `protect_from_forgery with: :null_session` — meaningless in an `api_only` app and misleading.
- `app/controllers/api/reserves_controller.rb:27` `params[:orderToSubmit] ||= {}` after the hash has already been dereferenced at line 21-22.
- `app/controllers/api/reserves_controller.rb:84-91` — commented-out authorization check ("requested user must be same as logged in user") that would have prevented part of SEC-01; either restore it or delete the comment and document why it is unnecessary.
- `app/models/user.rb:23-26` `User.find` — a stub returning `nil`.
- `app/controllers/api/print_controller.rb:2` `skip_before_action :verify_authenticity_token` — no such `before_action` is active in an API app.
- `app/controllers/api/print_controller.rb:50-55` `missing_fields` validates only `sublocation_id`, with a `# TBD` comment.

### BE-25 — `render_json` can raise on an unknown error code (Low)

**Where:** `app/controllers/application_controller.rb:17`.

`ErrorCodes.const_get(@response[:errors][:code])[:status]` raises `NameError` if a controller ever sets a code not defined in `config/initializers/status_codes.rb` (e.g. a typo, or a Koha-derived code). Since `error_msg` accepts any string, this is a latent 500.

**Suggestion.** `ErrorCodes.const_get(code, false) rescue ErrorCodes::INTERNAL_SERVER_ERROR`, or better: make `error_msg` accept the full constant and validate it.

---

## 4. Backend architecture & design

### ARC-01 — No HTTP timeouts, no connection reuse, no parallelism (High)

**Where:** every `RestClient.get` — `biblio.rb:155,166,170`, `location.rb:32`, `sublocation.rb:26`, `user.rb:34,48`, `reserve.rb:75`, `libris_controller.rb:30`, `subscription.rb`.

`Biblio.find_by_id` performs **four sequential** Koha round-trips (bib, subscriptions, items, reserves) per page view; `users/current` adds a fifth (`Biblio.find_by_id` at `users_controller.rb:14`) plus a member lookup. `RestClient` defaults to 10 s open / 60 s read, so one slow Koha call can occupy a Puma thread for over a minute; with `puma ~> 3.0` defaults (5 threads) the app deadlocks under load.

**Suggestion.** Set explicit `timeout`/`open_timeout` per call, run the independent items/reserves/subscriptions calls concurrently, add a circuit breaker, and add a request timeout at the Apache/Compose edge.

### ARC-02 — No caching of user or bibliographic data (High)

Only `Location.all` and `Sublocation.all` are cached (`location.rb:27`, `sublocation.rb:22`). Every page load re-fetches the full biblio, all items, all reserves and the patron record. This multiplies the SEC-09 credential-in-URL exposure and makes the app slow and fragile.

**Suggestion.** Cache biblio/item/reserve payloads briefly (60–300 s, keyed by biblio id) and patron data for the request duration only. Note that any caching must respect BE-01 (do not mutate cached objects).

### ARC-03 — Fire-and-forget thread for subscription orders (High)

**Where:** `app/models/koha.rb` `send_subscription_reserve` (`Thread.new { RestClient.post … }`).

The response is never inspected, exceptions inside the thread are swallowed (or crash the thread silently), there is no retry, and the HTTP request to the client has already been answered with 201. A failed subscription order is therefore invisible: the patron gets a printed slip and no hold.

**Suggestion.** Perform the call synchronously (it is on the critical path of a user-visible action) or move it to a real background job with retries and a failure surface. Never spawn bare threads inside a Rails request.

### ARC-04 — Business rules duplicated between client and server (High)

Loan types (`loan_type.rb:14-21`), pickup-location eligibility (`location.rb:39-98`), item availability and ordering rules (`item.rb:41-64`) are all re-implemented in the frontend (`server/api/loantypes.ts`, `locations.ts`, `biblios/[id].ts`, `ItemsTable.vue`). The server then trusts the client's conclusions (SEC-03).

**Suggestion.** Single source of truth in the backend; the frontend should render decisions, not compute them. Where client-side filtering is needed for UX, keep it but always re-validate on submit.

### ARC-05 — Hard-coded reference data in Ruby (Medium)

`LoanType::LOAN_TYPES`, the sigel↔library map in `biblio.rb:89-100` (duplicated in `libris_controller.rb:92-104`), the `restricted`/`withdrawn`/`itemlost` code sets in `item.rb`, and the MARC `RECORD_TYPES` table.

**Suggestion.** Move to data files under `config/data/` (the `locations.json` pattern already exists) or fetch from Koha, and share the sigel map between `Biblio` and `LibrisController`.

### ARC-06 — `Koha` model is a thin wrapper with no error handling (Medium)

`app/models/koha.rb` has no timeouts, no status checks, no logging; `reserve_notes` builds Swedish note text.

**Suggestion.** One HTTP client object with timeouts, retries, structured logging (with PII filtered) and typed results.

### ARC-07 — `Print` writes to a global directory with no error handling (Medium)

`print.rb:181-190`: if `/opt/bestall-files` is missing/unwritable, `pdf.render_file` raises and the order fails mid-way (after the hold may already have been created). Labels are hard-coded Swedish (`print.rb` throughout), so the printed slip is not localised even though the web UI is.

**Suggestion.** Wrap the write, verify the directory at boot, and move labels into i18n data shared with the frontend.

### ARC-08 — `ApplicationController < ActionController::Base` in an API-only app (Low)

`config/application.rb:36` sets `config.api_only = true`, yet controllers inherit `ActionController::Base` (view rendering, forgery protection, cookies). `Api::ConfigController` inherits `Api::ApiController` while every other controller inherits `ApplicationController` directly — inconsistent hierarchy.

**Suggestion.** Inherit `ActionController::API`, delete `protect_from_forgery`, and make all API controllers inherit `Api::ApiController`.

### ARC-09 — `APP_CONFIG` is a global constant built in an initializer (Low)

`config/initializers/load_config.rb:6-8`: `APP_CONFIG = secret_config.merge(locations)` — a top-level constant (reload warnings in development), parsed with `YAML.load(ERB.new(...).result(binding))` (ERB-in-YAML means an env var containing YAML metacharacters can break or alter the config structure), and it mixes secrets with reference data.

**Suggestion.** Wrap in a `Config` service object (`Rails.application.config.x`), use `YAML.safe_load`, and validate required keys at boot with a clear error.

### ARC-10 — No request ID / correlation across the three tiers (Low)

Rails logs `log_tags = [:request_id]` (`production.rb:53`) but the frontend does not forward `X-Request-Id` to the backend, so a failing order cannot be traced end-to-end.

**Suggestion.** Propagate `X-Request-Id` from Nitro `$fetch` calls to Rails.

### ARC-11 — No health/readiness endpoint (Medium)

There is no `/up` or `/health` route (Rails' default health check requires `config.host_authorization` and is not configured), so neither Docker (`healthcheck:` absent in all Compose files) nor Apache can detect a dead backend.

**Suggestion.** Add a lightweight `/up` controller action and Compose `healthcheck`s.

### ARC-12 — Concurrency and thread-safety of models (Medium)

Models mutate shared cached structures (BE-01) and rely on instance-level state without synchronisation. With Puma threads, cached `Location` objects are mutated concurrently by different requests.

**Suggestion.** Treat cached models as immutable value objects.

---

## 5. Frontend correctness bugs

### FE-01 — Loan-type filtering is dead code; the SD restriction never applies (Critical)

**Where:** `frontend/server/api/loantypes.ts:33-56, 63-89`.

- ~~`filteredExtendedLoanTypes` (lines 64-82) is computed and **never returned** — line 85 returns `extendedLoanTypes`. The "only SD/FT may see loan type 5" rule therefore never runs.~~
- ~~`isLoantypeDisabled` (lines 33-56) is never called, and if it were it would throw `ReferenceError`: `not_for_loan` and `item_type` (lines 49-50) are not defined in scope.~~
- ~~The three runtime-config keys it reads — `disableLoantypeHomeAndPickupForNotForLoan`, `disableLoantypeHomeAndPickupForItemTypes`, `includeLoantypeSDForUserCategories` — are **not declared** in `nuxt.config.ts` `runtimeConfig.public`, so they are always `undefined` and the lists default to `[]`.~~

Net effect: the UI shows loan types that the library intends to hide, and the server does not compensate (SEC-03).

**Suggestion.** Return `filteredExtendedLoanTypes`; delete or fix `isLoantypeDisabled` (pass `current_item` fields explicitly); declare the three keys in `runtimeConfig.public` and add them to `docker/.env` + Ansible vars; add a unit test for the filter.

### FE-02 — `Object.assign` on arrays: `resetLoanTypes`/`resetLocations` do nothing (High)

**Where:** `frontend/app/composables/useLoantypes.ts:9-15`, `useLocations.ts:31-37` (as compiled into `app/composables/`), consumed in `pages/order/[id]/details.vue:184-199`.

```ts
const setLoanTypes = (data: Partial<LoanType>) => {
  Object.assign(loanTypes.value, data);
};
const resetLoanTypes = () => {
  Object.assign(loanTypes.value, []);
};
```

`Object.assign` on an array target copies indices but never changes `length`:

- `resetLoanTypes()` is a **no-op** — the comment "Clear loan types before setting new ones to avoid showing stale data" is false.
- `setLoanTypes(shorterArray)` leaves the tail of the previous array in place, so a user can see (and select) loan types/locations belonging to a different item.
- The parameter types are wrong (`Partial<LoanType>` instead of `LoanType[]`).

**Suggestion.** `loanTypes.value = data` and `loanTypes.value = []`; fix the signatures; add a typecheck step (FEA-05) so this class of error is caught.

### FE-03 — `viewType: "collection"` is unreachable; book view loses `items` (High)

**Where:** `frontend/server/api/biblios/[id].ts:60-113`.

The first branch handles `!subscriptiongroups?.length && !has_item_level_queue`, the second handles the exact negation, so the third branch (`!subscriptiongroups?.length && has_item_level_queue`, lines 104-112) can never run. Consequences:

- ~~Collection records (`record_type: collection`, `queue_level: 'item'`) are rendered with `viewType: "subscription"` instead of `"collection"`, so `view/collection.vue` is dead and the missing i18n key `viewType.collection.copies` (I18N-01) is never even reached.~~
- ~~The first branch builds `itemsAvailable`/`itemsNotAvailable` but **does not set `items`**, while the second branch sets `items` but not the split arrays — the two shapes are inconsistent, and `order/[id].post.ts:44-46` clears both.~~

~~**Suggestion.** Make the branches exhaustive and mutually exclusive (`if (subscriptiongroups?.length) … else if (has_item_level_queue) … else …`), always emit `items`, and add a unit test per record type.~~

### FE-04 — Error handling crashes when the backend is unreachable (High)

**Where:** `frontend/server/api/biblios/[id].ts:132-135,206`.

```ts
} catch (error: FetchError | any) {
  switch (error.response.status) {   // TypeError when there is no response
…
  errors: [{ code: "UNKNOWN_ERROR", detail: error.value.message }]  // error.value does not exist here
```

A connection failure, DNS failure or timeout (all likely when the Rails container restarts) throws a `TypeError` inside the `catch`, producing an opaque 500 instead of the intended `SERVER_ERROR` payload. `error.value.message` is a copy/paste from a component context and is always a crash.

**Suggestion.** `const status = (error as any)?.response?.status ?? (error as any)?.statusCode;` and use `error?.message` in the default case. Add a test with a stubbed network failure.

### FE-05 — `JSON.parse` of query parameters without validation (High)

**Where:** `server/api/loantypes.ts:26`, `locations.ts:32-35`.

`current_item`/`current_subscription` arrive as query strings and are `JSON.parse`d with no `try/catch`. Worse, the caller in `pages/order/[id]/details.vue:175-196` passes **objects** in `query:` (`current_item: currentItemOnOrder?.value`), which ofetch serialises as `"[object Object]"` → `JSON.parse` throws → 500 whenever an item-level order is in progress.

**Suggestion.** Send these as a POST body (the backend call already uses POST), or parse with `destr()`/`try/catch` and validate the shape. Add a test for the item-level order path.

### FE-06 — Broken type import paths in `app/` (High)

~~### FE-06 — Broken type import paths in `app/` (High)~~

~~**Where:** `app/pages/order/[id]/index.vue:9-12`, `app/pages/order/[id]/details.vue` (same four imports), `app/components/view/book.vue`, `app/components/view/collection.vue`, `app/components/view/subscription.vue`, `app/error.vue:3`.~~

~~They import from `~/types/…` (and `~/shared/types/…`). In Nuxt 4 `~/` is `app/`, and there is no `app/types/` directory — the types live in `shared/types/` and must be imported as `#shared/types/…` (as the server routes correctly do). Because these are type-only imports they are erased at build time, so the app "works", but `vue-tsc`, IDE navigation and any future type-aware tooling are broken.~~

~~**Suggestion.** Replace with `#shared/types/...` everywhere and enable `vue-tsc --noEmit` in CI.~~
~~**Suggestion.** Replace with `#shared/types/...` everywhere and enable `vue-tsc --noEmit` in CI.~~

### FE-07 — GitHub sign-in resolves the wrong account (High)

**Where:** `frontend/server/api/auth/[...].ts:171-178` and `:130-140`.

The custom GitHub `profile()` returns `{ id, name, email, xaccount }`, but the `jwt` callback reads `profile.account`:

```ts
const xaccount = runtimeConfig.xaccountMapToGithub ? … : profile.account;
token.account = xaccount;
```

Unless `NUXT_XACCOUNT_MAP_TO_GITHUB` is set, `profile.account` is `undefined` → `token.account` undefined → `getUserData(undefined)` in the `session` callback (`:89`) requests `/users/current` with header `current-username: undefined` → "Could not find user". The GitHub login path is effectively broken for anyone not covered by the mapping variable.

**Suggestion.** Use `profile.xaccount`, and add a fallback plus an explicit error when no Koha account can be resolved.

### FE-08 — Auth middleware ignores the `loading` state and sends authenticated users to `/error` (High)

**Where:** `frontend/app/middleware/auth.js:72-95`.

- With `ssr: false` (see `nuxt.config.ts:78`), `useAuth().status` is `"loading"` on first client render. The middleware only branches on `authenticated`/`unauthenticated`, so during loading it lets the page through; the page then calls `/api/currentuser` (401) or `/api/biblios/:id` with no session → error page. This is the most likely cause of intermittent "sign in again" / error-page reports.
- An already-authenticated user who opens `/login` is redirected to `/error` (line 80) — a route that is not a page; Nuxt renders its error document with no error object, producing a confusing generic error.

**Suggestion.** Handle `status === 'loading'` (await the session or render a loader), and redirect authenticated users on `/login` to the `redirect` query target or the home page.

### FE-09 — `handleSignOut` called with an argument it does not accept (Medium)

**Where:** `app/pages/index/[id].vue:20-24` vs `app/composables/useAppSignOut.ts:51`.

`await handleSignOut({ redirect: false })` — the function takes no parameters and always navigates to `/login`. In a page whose purpose is to _immediately_ navigate onward to `/order/:id`, this produces a sign-out followed by a navigation to `/login`, i.e. the user loses the order flow. It is also a TypeScript error (too many arguments).

**Suggestion.** Give `handleSignOut` an options object (`{ redirect?: boolean }`) and honour it, or add a separate `signOutSilently()`.

~~### FE-10 — `OrderDenied.vue` is dead code and would crash if used (Medium)~~

~~**Where:** `app/components/OrderDenied.vue` (123 lines, referenced nowhere — verified by component-usage scan), including an unguarded `errors.length` access.~~

~~Meanwhile `error.vue:129-142` re-implements the same error list inline. Two implementations of the same UI, one of them broken.~~

~~**Suggestion.** Delete `OrderDenied.vue` or refactor `error.vue` to use it; add a component test.~~

~~### FE-11 — `contact.post.ts` is a fake endpoint that logs and echoes PII (High)~~

~~**Where:** `frontend/server/api/contact.post.ts`.~~

~~- No message is sent anywhere — the handler waits 1 s and returns success. Users believe they have contacted the library (a real accessibility/support failure).~~
~~- `console.log("Contact request received:", …)` appears **twice** (lines 3 and 23) and dumps name, email, message.~~
~~- The `if (!contactRequest)` guard (lines 16-21) is **after** the property accesses (lines 5-15), so it is unreachable and would not help anyway.~~
~~- No email format validation, no length limits, no rate limiting, no CSRF protection, and the response echoes the user's input back.~~

~~**Suggestion.** Implement the actual delivery (SMTP/API), validate and sanitise, rate-limit, log only a correlation id, and return a fixed success payload.~~

~~### FE-12 — `force` query parameter typed boolean but arrives as a string (High)~~

~~**Where:** `frontend/server/api/biblios/[id].ts:20-21`.~~

~~`force = force ?? false` leaves the string `"false"` (truthy) in place, which is then interpolated into the backend URL — see SEC-04 for the consequence.~~

**Suggestion.** `const force = getQuery(event).force === "true";`

### FE-13 — Authentication check commented out on the biblio proxy (Medium)

**Where:** `frontend/server/api/biblios/[id].ts:12-15` (and the commented-out `body:`/`current_user` block at `:119-127`).

`getServerSession` is fetched and then unused. Catalogue data is arguably public, but the endpoint also forwards a `current-username` header derived from the session, and the backend's own restriction is disabled by SEC-04 — so the only remaining gate is this commented-out check.

**Suggestion.** Re-enable the 401 check (or document explicitly that this route is intentionally public) and remove the dead code.

### FE-14 — `verifyMaterial/[id].ts` is an unauthenticated, unvalidated proxy (Medium)

**Where:** `frontend/server/api/verifyMaterial/[id].ts:5-25`.

No session check; the `id` route parameter is interpolated into the backend URL without validating it is numeric, so `?`/`#`/`/` characters alter the upstream request path. `error.data` is read without optional chaining.

**Suggestion.** Validate `id` against `/^\d+$/` and return 400 otherwise; use `encodeURIComponent`; add the session check for consistency with the other routes.

### FE-15 — `try { return x } catch { return error }` anti-pattern (Medium)

**Where:** `server/api/loantypes.ts:84-89`, `locations.ts:49-56` (including a leftover `console.log("Seeding completed.")`).

A `return` cannot throw, so the `catch` is unreachable; if it were reachable, returning an `Error` object from a handler serialises it into the response body.

**Suggestion.** Remove the wrappers; put error handling around the actual `$fetch` calls.

~~### FE-16 — `showError` does not stop execution (Medium)~~

~~**Where:** `app/pages/index/[id].vue:32-55`, `app/pages/index.vue:11-28`, `app/pages/order/[id]/index.vue:16-44`.~~

~~After `showError(...)` the code continues into `else if`/further `useFetch` calls, so several errors can be raised for one request and the last one wins. `statusCode: "unknown code"` / `"redirect"` are strings where Nuxt expects numbers.~~

~~**Suggestion.** `return showError(...)` and use numeric status codes with a separate `data.kind` marker for the redirect case.~~

### FE-17 — `index.vue` always errors on `/` (Medium)

**Where:** `app/pages/index.vue:11-28`.

`route.params.id` never exists for `/`, so the MISSING_ID error is unconditional. Also `navigateTo(localePath("/closed"))` (line 7) is not returned/awaited, so the closed-site redirect races with the error.

**Suggestion.** Decide the intended behaviour for `/` (redirect to a search entry point or a landing page) and implement it with `return navigateTo(...)`.

### FE-18 — `setOrder({ user: … })` writes a field that is not in the `Order` type (Medium)

~~### FE-18 — `setOrder({ user: … })` writes a field that is not in the `Order` type (Medium)~~

~~**Where:** `app/pages/order/[id]/index.vue:57-60` vs `shared/types/Order.ts:98-108` and `composables/useOrder.ts:4-14`.~~

~~`user` is not part of `Order`/`emptyOrder`, so `resetOrder()` never clears it and the type system does not describe the real payload that is POSTed to `/api/order/:id` (and thence to Rails).~~

~~**Suggestion.** Add the field to the type (or remove it from the payload — the backend derives the user from the header anyway).~~

### FE-19 — `error.vue` navigates and fetches without guards (Medium)

**Where:** `app/error.vue:76-90,102`.

`fetchBiblioDetails()` + `window.location.href = biblio.value.redirect_url` run for _every_ error page view (including 404s of unrelated routes), and the redirect target is unvalidated (SEC-13). `biblio` is typed loosely, and `error.statusCode`/`error` are dumped to the page when `debugInfo` is on — which is enabled in `docker/.env`-driven deploys if `NUXT_DEBUG_INFO` is mis-set, leaking stack traces to end users.

**Suggestion.** Only fetch when the errored route matches `/order/:id`; validate the redirect; ensure `debugInfo` cannot be enabled outside dev/lab.

### FE-20 — Debug/test pages and components shipped to production (Medium)

**Where:** `app/pages/test.vue` (177 lines simulating the discovery-portal entry links), `app/pages/docs.vue` + `app/components/docs/*` (a style-guide site, including `onclick="alert('Search button clicked')"` in `docs/search.vue:18`), `app/components/Header.vue`, `app/components/BaseModal.vue`, `app/components/OrderDenied.vue`, `app/components/icons/info.vue` (all unreferenced).

**Suggestion.** Move docs/test routes behind a dev-only guard or delete them; delete the unreferenced components (they are dead weight in the bundle and mislead future readers).

### FE-21 — No timeouts, retries or circuit breaking on backend calls (High)

**Where:** all `server/api/**` handlers (`$fetch`/`fetch` without `timeout`), plus `auth/[...].ts:47-50` (`fetch` in the session callback).

Nitro/ofetch has no default timeout, so a hung Rails container blocks the Node event loop's request indefinitely and exhausts sockets; the session callback failure additionally logs users out (SEC-18).

**Suggestion.** Set `timeout: 5000` (and `retry: 0` for writes, `retry: 1` for idempotent reads), and surface a friendly "library system unavailable" state.

### FE-22 — `useErrorCodes` duplicates the backend error table (Medium)

**Where:** `app/composables/useErrorCodes.ts` vs `config/initializers/status_codes.rb`.

Two hand-maintained copies of the same code↔HTTP-status mapping, already divergent (the frontend has `INVALID_DATA`, the backend has `UNPROCESSABLE_ENTITY`/`BAD_REQUEST`).

**Suggestion.** Generate one shared list (e.g. a JSON file consumed by both, or expose `ErrorCodes` via `/api/config`).

---

## 6. Frontend architecture

~~### FEA-01 — `ssr: false` with a full Nitro server tier (Medium)~~

~~`nuxt.config.ts:78` disables SSR (with an `experimental.viteEnvironmentApi: true` workaround for a Nuxt 4.4.5 `ssr:false` regression at `:73-75`). The app is therefore a client-rendered SPA plus an API proxy, which costs SEO, first-paint, and makes `error.vue` behave oddly (errors are mostly client-side), while still paying for a Node server.~~

~~**Suggestion.** Either re-enable SSR once the upstream regression is fixed, or drop the pretence and document the SPA+proxy architecture; remove the `experimental` flag when upgrading Nuxt.~~

### FEA-02 — Whole biblio payload kept in shared state and POSTed back (Medium)

`app/pages/order/[id]/index.vue:59` stores `fullBiblio` in `useState`, and `server/api/order/[id].post.ts:36-47` forwards it (minus items) to Rails, which reads `has_item_level_queue` and `default_queue_location` from it (`reserves_controller.rb:53,60`). Client-supplied data is part of the write path (SEC-03, BE-05).

**Suggestion.** Send only ids; let the backend re-load the biblio.

### FEA-03 — Duplicated localisation logic in three places (Medium)

Locale-dependent name selection happens in `server/api/biblios/[id].ts`, `server/api/locations.ts`, `server/api/loantypes.ts`, and again in components (`ItemsTable.vue`, `subscription.vue`). Backend Swedish/English suffixes are appended in Ruby (`location.rb:51-92`) and cannot be localised.

**Suggestion.** Return `name_sv`/`name_en` plus a machine-readable `disabled_reason` from the backend; do all localisation in the frontend via i18n.

### FEA-04 — No linting, formatting, typecheck or test tooling (High)

`frontend/package.json` has **no devDependencies and no scripts** beyond the Nuxt defaults: no ESLint, no Prettier check, no `vue-tsc`, no Vitest, no Playwright. The bugs in FE-01, FE-02, FE-06, FE-07, FE-09 would all have been caught by a typecheck step.

**Suggestion.** Add `eslint` + `@nuxt/eslint`, `vue-tsc --noEmit`, `vitest` for composables/server handlers, and a CI job running them.

### FEA-05 — Runtime config surface is unvalidated and half-used (Medium)

`nuxt.config.ts:3-58` declares 8 private and ~30 public keys, all defaulting to empty strings/false. Thirteen declared keys are never read anywhere (`dateFormat`, `escapeHtml`, `guPrivacyUrlEn/Sv`, `htmlAttrs`, `include`, `link`, `localeParamName` in some paths, `reserveNoteMaxLength`, `showStatusLimitationToast`, `strictMessage`, `toastDurationMs`, `type`, …) while three keys that _are_ read are not declared (FE-01). Empty defaults mean a mis-deployed environment silently degrades instead of failing.

**Suggestion.** Validate required keys at boot (`if (!config.apiBase) throw …`), delete unused keys, and document the remaining ones in one table.

### FEA-06 — `useState` for the order is session-long and unbounded (Low)

`composables/useOrder.ts:48` keeps the entire biblio (items, subscriptions, display info) in shared state for the lifetime of the SPA session.

**Suggestion.** Store ids and re-fetch, or scope the state to the order routes.

### FEA-07 — Component naming inconsistency (Low)

`components/view/*.vue` are auto-imported as `<ViewBook>`, `<ViewItemsTable>` etc., while file names mix `PascalCase` (`ItemsTable.vue`, `BackToTopLink.vue`) and `lowercase` (`book.vue`, `nav.vue`, `hero.vue`, `responsivness.vue` — also a typo of "responsiveness").

**Suggestion.** Standardise on PascalCase file names.

### FEA-08 — `app.vue` sets the head title with `$t` in `<script setup>` (Low)

`app.vue:1-8` relies on the i18n auto-import of `$t` outside a component template; with `ssr:false` this is fine, but it is fragile across i18n major versions (v10 is installed).

**Suggestion.** Use `useHead({ title: computed(() => t('site.title')) })` with `const { t } = useI18n()`.

~~### FEA-09 — Unused dependency (Low)~~

~~`xml2js` is in `dependencies` but is not imported anywhere in `app/`, `server/` or `shared/`.~~

~~**Suggestion.** Remove it (it also drags in a larger attack surface than needed).~~

---

## 7. Backend ↔ frontend contract mismatches

### CT-01 — `is_availible` typo is part of the public API (High)

**Where:** `app/models/item.rb:31,42` → `frontend/shared/types/Biblio.ts:30`, `frontend/server/api/biblios/[id].ts:65,68`, `app/components/view/ItemsTable.vue:196`. (Also `availibleLocales` in `LocaleSwitcher.vue:4,23`.)

**Suggestion.** Emit both `is_available` and (deprecated) `is_availible` for one release, switch the frontend, then drop the typo. Add a contract test.

### CT-02 — `Subscriptiongroup` vs `SubscriptionGroup` (Medium)

Backend model/JSON key is `subscriptiongroups` with class `Subscriptiongroup`; the frontend type is `SubscriptionGroup` (`shared/types/Biblio.ts:36`). Harmless at runtime, but it makes grep-based reasoning unreliable.

### CT-03 — `Location` TS type does not match the payload (Medium)

`shared/types/Location.ts:113-126` declares `location_id`, `is_open_loc`, `is_paging_loc`, `is_open_pickup_loc`, `is_kursbok_loc`, `sublocations` — but `Api::PickupLocationsController` renders `Location#as_json(include_sublocations: false)`, whose attributes are `id, name_sv, name_en, categories, pickup_location_id, is_disabled, monitored_reading_room`. The declared fields are Sublocation fields, so any component relying on them reads `undefined`.

**Suggestion.** Split the types (`Location`, `Sublocation`, `PickupLocationView`) and generate them from the API (e.g. via a JSON schema or OpenAPI document).

### CT-04 — camelCase in JSON responses (Medium)

`Reserve` (`showQueuePosition`, `positionInQueue`, `pickupLocation_en`), `reserves_controller.rb:41-43` (`showPickupLocation`), `config_controller.rb:17` (`registrationurl`, `myloansurl`). Mixed with snake_case everywhere else.

**Suggestion.** Standardise on snake_case (or configure `ActiveSupport::JSON.encode` with a key transform) and update the frontend types in one pass.

~~### CT-05 — `showRequiredPickupCode` exists only in the frontend (Medium)~~

~~### CT-05 — `showRequiredPickupCode` exists only in the frontend (Medium)~~

~~`app/composables/useOrder.ts:25,42` initialises it; no backend code ever returns it (verified: `Reserve` has no such attribute), and `confirm.vue` never reads it — the pickup code block is static text. Either a feature is missing or the state is vestigial.~~

### CT-06 — `Biblio` TS type is missing fields the backend sends (Medium)

`redirect_url`, `has_biblio_level_queue`, `can_be_borrowed`, `multi_volume`, `no_in_queue` semantics, `biblio_call_number` typed as `null` (literal) rather than `string | null` (`shared/types/Biblio.ts:70,73,74`).

### CT-07 — Apache proxies a route that does not exist (High)

`ansible/templates/sites/bestall.conf.j2:50-51` proxies `/api/reserve`, but the Rails route is `/api/reserves` (`config/routes.rb:6`). Any Koha-initiated order through this path 404s.

**Suggestion.** Fix the proxy path (or add an explicit alias route) and add a smoke test that hits every proxied path.

### CT-08 — Error payload shape is duplicated and inconsistent (Medium)

The backend emits `{errors: {code, detail, errors: [...], data}}` (`application_controller.rb:22-29`); `pages/index.vue:15-27` fabricates `{data: {data: {errors: {errors: […]}}}}`; `server/api/biblios/[id].ts` throws `createError({data: customError})`; `error.vue:129-135` then digs through `error?.data?.data?.errors.errors`. Three shapes, one fragile reader.

**Suggestion.** Define one error envelope, document it, and produce it in exactly one place per tier.

---

## 8. i18n & accessibility

### I18N-01 — Missing key `viewType.collection.copies` (Medium)

Used at `app/components/view/collection.vue:27`, absent from both `i18n/locales/en.json` and `sv.json` (verified programmatically: 143 keys in each, no key present in one and missing in the other; exactly one statically-used key missing). vue-i18n logs a warning and renders the key path.

### I18N-02 — Most order-denial error codes have no translation (High)

`error.vue:137` and `OrderDenied.vue` look up `orderDenied.errors.<CODE>` dynamically. Only 8 keys exist (`ALREADY_BORROWED`, `ALREADY_RESERVED`, `CAN_NOT_BE_BORROWED`, `FORBIDDEN`, `ITEM_NOT_FOUND`, `MISSING_ID`, `RESTRICTION_AV`, `UNRECOGNIZED_ERROR`). The backend can emit `AGE_RESTRICTED`, `ITEM_ALREADY_ON_HOLD`, `TOO_MANY_RESERVES`, `NOT_RESERVABLE`, `CANNOT_RESERVE_FROM_OTHER_BRANCHES`, `TOO_MANY_HOLDS_FOR_THIS_RECORD`, `BORROWER_NOT_FOUND`, `BRANCH_CODE_MISSING`, `ITEMNUMBER_OR_BIBLIONUMBER_IS_MISSING`, `DAMAGED`, `ITEM_DOES_NOT_BELONG_TO_BIBLIO`, plus `UNAUTHORIZED`, `NOT_FOUND`, `BAD_REQUEST`, `UNPROCESSABLE_ENTITY`, `INTERNAL_SERVER_ERROR`, and the never-emitted `RESTRICTION_FINES`/`RESTRICTION_OVERDUE` (BE-15). For all of these the user sees an **empty bullet** in the error list.

**Suggestion.** Add keys for every code in `Reserve.error_code`'s known list and every `ErrorCodes` constant; add a CI check that extracts the Ruby code list and asserts each has both locales.

~~### I18N-03 — `lang` attribute contradicts the default locale (Medium)~~

~~`nuxt.config.ts:60-64` sets `htmlAttrs.lang = "en"` while `i18n.defaultLocale = "sv"` with `strategy: "prefix_except_default"` — Swedish pages are announced to screen readers as English (wrong pronunciation rules).~~

~~**Suggestion.** Let `@nuxtjs/i18n` manage `lang` (it does so automatically when `htmlAttrs.lang` is not hard-coded).~~

### I18N-04 — Untranslated UI strings (Low)

`app/pages/login.vue:41` renders the literal `For developers`; `app/models/print.rb` prints Swedish-only labels; `app/models/loan_type.rb` carries both languages but `reserves_controller.rb:130` always prefixes the hold note with Swedish `"Lånetyp:"`.

### I18N-05 — Debug string in a production component (Medium)

`app/components/docs/search.vue:18` — `onclick="alert('Search button clicked')"`.

### I18N-06 — Accessibility gaps (Medium)

- `v-html` blocks (SEC-12) bypass Vue's escaping and often break screen-reader semantics.
- `error.vue:105-133` builds its list from `error?.data?.data?.errors.errors` with `:key="index"` and no list semantics beyond `<ul>`.
- `app/pages/index/[id].vue` renders an empty `<div>` while it decides where to go — nothing is announced, and the route change is silent (mitigated by `NuxtRouteAnnouncer` in `app.vue:17`).
- `app/components/view/ItemsTable.vue` renders a data table with interactive controls; verify column headers/`scope` and focus order.

**Suggestion.** Run an axe/Playwright a11y pass in CI; the repo already ships an accessibility-report link, so regressions are visible to the public.

---

## 9. Dependencies & supply chain

### DEP-01 — `rspec-rails ~> 3.5` (3.9.1) with Rails 7.2.1 (Critical for testability)

`Gemfile:32`, `Gemfile.lock:224`. rspec-rails 3.9 targets Rails 5.x. On Rails 7.2 its internals (`ActiveSupport::Reloader` hooks, `fixture_path`, `infer_spec_type_from_file_location!` integration) break. Combined with `rails_helper.rb:25` (`ActiveRecord::Migration.maintain_test_schema!`) and **no `config/database.yml`**, the suite almost certainly cannot even boot (see TEST-01).

**Suggestion.** Upgrade to `rspec-rails ~> 7.0` (matching Rails 7.2), remove the ActiveRecord line, and re-run the suite.

### DEP-02 — `shoulda` 4.0 / `shoulda-matchers` 4.5 (High)

`Gemfile:39`, `Gemfile.lock:234-238`. shoulda-matchers 4.x predates Rails 6 and will misbehave or raise on Rails 7.2. Also, most matchers require ActiveRecord, which this app does not use.

### DEP-03 — Puma `~> 3.0` (resolved 3.12.6) (High)

`Gemfile:12`. Puma 3.x is EOL (known CVEs in the 3.x line, no keep-alive/HTTP security fixes, no `fork`-safe worker tuning for modern kernels). Rails 7.2 ships guidance for Puma 6.

**Suggestion.** Upgrade to Puma 6.x and re-tune `config/puma.rb` (`threads`, `workers`, `plugin :tmp_restart`).

### DEP-04 — Prawn `~> 1.3.0` (High)

`Gemfile:20` pins Prawn 1.3 (2014-era) with the comment that 2.5.0 broke diacritics in the bundled Roboto fonts. This pins the app to an ancient PDF library (and its `ttfunk`/`pdf-core` dependencies) for a decade.

**Suggestion.** Re-test with a current Prawn (2.4+) and the `lib/fonts/Roboto-*.ttf` files; if the diacritics bug persists, fix the font registration (`Prawn::Document#font_families`) rather than pinning forever.

### DEP-05 — `rest-client ~> 2.0.1` is deprecated (Medium)

`Gemfile:18`. The gem is unmaintained; it also lacks sane default timeouts (ARC-01).

**Suggestion.** Move to `net/http` + `rubyzip`-free plain `Net::HTTP`, `httparty`, or `faraday` with explicit timeouts, retries and instrumentation.

### DEP-06 — Gems that are not used (Medium)

- `jquery-rails` (`Gemfile:17`) — the frontend is Nuxt; the Rails asset pipeline is dead code here.
- `database_cleaner` (`:34`) → pulls `database_cleaner-active_record`; there is no database.
- `jwt` (`:23`) — no token verification exists (ironically the fix for SEC-01 would use it).
- `factory_bot_rails` (`:33`) — the factories are trivial and unused by most specs.
- `tzinfo-data` for Windows platforms — irrelevant for Linux containers, harmless but noise.
- `byebug` in the test group — allows `debugger` to slip into CI runs.

### DEP-07 — No Ruby version pinning (High)

There is no `.ruby-version`, no `required_ruby_version` in the `Gemfile`, and the backend image is `docker.ub.gu.se/rails:ruby-3.2.2` (an external, unpinned-by-digest base). `Gemfile.lock` says `BUNDLED WITH 2.4.10` and `PLATFORMS: ruby`.

**Suggestion.** Add `.ruby-version` + `required_ruby_version`, pin the base image by digest, and commit a lockfile generated by a documented bundler version.

### DEP-08 — Frontend dependencies are floating carets with no CI lockfile enforcement (Medium)

`frontend/package.json` uses `^` for `nuxt`, `vue`, `vue-router`, `@nuxtjs/i18n`, `@sidebase/nuxt-auth`, `next-auth`. `next-auth ^4.21.1` is a React library being used through `@sidebase/nuxt-auth` — a compatibility shim whose patch-level behaviour changes matter a lot (auth is the most fragile part of this app).

**Suggestion.** Use `npm ci` in the Dockerfile (currently `npm install`, `frontend/build/frontend/Dockerfile:15` and `Dockerfile.dev:36`), and enable Dependabot/Renovate with a smoke test.

### DEP-09 — `Gemfile` hygiene (Low)

Empty `group :development do end` (`Gemfile:42-43`), commented-out `spring` gems (`:30-31`) while `config/spring.rb` still exists, and a `git_source(:github)` block that is never used.

### DEP-10 — Rack version expectation (Low)

`Gemfile.lock` resolves `rack 3.1.8` (via Rails 7.2). Any assumption of Rack 2 in middleware choices (e.g. older `rack-cors` behaviour) should be re-verified; `rack-cors` is unpinned in the `Gemfile`.

---

## 10. Rails configuration & dead code

### CFG-01 — `ENVIRONMENT: production` for every host, including dev and lab (High)

`ansible/vars/default_env.yml:6` sets `ENVIRONMENT: production`; `docker/docker-compose.yml:55` maps it to `RAILS_ENV`. No host-specific `env.yml` overrides it (verified: `ENVIRONMENT` appears only in `default_env.yml`). So dev/lab/staging containers run the **production** Rails environment: eager loading, `consider_all_requests_local = false`, no reload, production logging.

Consequences: `config/environments/lab.rb` and `staging.rb` (with their `log_level = :debug`) are **never used** — they are dead configuration; and dev/lab behave unlike their names suggest.

**Suggestion.** Set `ENVIRONMENT` per host (`vars/<host>/env.yml`) and add a boot-time log line asserting `Rails.env` matches the intended stage.

### CFG-02 — `config.hosts` unset in production; `[/.*/]` in development (Medium)

`config/environments/production.rb:80-86` (commented out), `development.rb` sets `config.hosts = [/.*/]`. With Apache sending `Host: localhost:<port>` (`ProxyPreserveHost Off`), host authorization cannot be used as-is, so DNS-rebinding protection is off.

**Suggestion.** Set `config.hosts = ["bestall-server-<stage>.ub.gu.se", "localhost", "127.0.0.1"]` per environment.

### CFG-03 — `force_ssl = false` and no HSTS (Medium)

`production.rb:45`, `lab.rb`, `staging.rb`. TLS is terminated at Apache, which does redirect `:80 → https` for named vhosts but sends no HSTS header and sets no secure-cookie flags.

**Suggestion.** `config.assume_ssl = true` + `config.force_ssl = true` (or add HSTS in Apache: `Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"`).

### CFG-04 — `config/secrets.yml` with literal dev/test `secret_key_base` (Medium)

Deprecated mechanism; also means a known signing key is in the repository.

**Suggestion.** Delete the file; rely on `SECRET_KEY_BASE` (already wired for lab/staging/production) and Rails credentials for dev/test.

### CFG-05 — Rails 5-era initializers in a Rails 7.2 app (Low)

`config/initializers/new_framework_defaults.rb` (Rails 5.0/5.1 toggles), `session_store.rb`, `cookies_serializer.rb`, `wrap_parameters.rb` — all irrelevant to an API-only app, and `session_store.rb` actively suggests sessions are in use.

**Suggestion.** Delete them; keep `filter_parameter_logging.rb` (expanded per SEC-09) and `content_security_policy.rb` only if a CSP is actually emitted.

### CFG-06 — `config/application.rb` requires `rails/test_unit/railtie` (Low)

`application.rb:9` while the project uses RSpec exclusively. Also `config.load_defaults 7.1` on Rails 7.2.1 (`:18`) — deliberate during an upgrade, but should be bumped and the 7.2 defaults reviewed.

### CFG-07 — Dead application code (Medium)

- `app/views/**` (ERB layouts + mailer templates) — no HTML is ever rendered.
- `app/mailers/application_mailer.rb` — never invoked; `action_mailer/railtie` is required in `application.rb:7` for nothing.
- `app/assets/**` — Rails-side JS/CSS (including ActionCable channel scaffolding) that duplicates what the Nuxt app does.
- `app/helpers/**` — eight empty helper modules.
- `app/controllers/concerns/`, `app/models/concerns/` — empty directories.
- `public/assets/**`, `config/deploy.yml.sample`, `lib/capistrano/tasks/create_version.rake`, `config/spring.rb`, `config/locales/en.yml` (Rails default) — leftovers from the pre-Nuxt/Capistrano era.

**Suggestion.** Delete in one cleanup PR; it removes ~40 files of misleading context and shortens the eager-load path.

### CFG-08 — `config_secret.yml` is the live config and is committed (Medium)

`config/config_secret.yml` (ERB + ENV), `config_secret.yml.sample`, `config_secret.test.yml`. The sample is out of date relative to the live file (missing `cas_url`, `frontend_hostname`, `oauth2:`, `cache:`, `show_pickup_code`), so a new environment built from the sample silently mis-configures (`APP_CONFIG['cache']['api_key']` → BE-14/SEC-14 crash).

**Suggestion.** Keep one `config_secret.yml.example` generated from the live file with placeholders, and validate required keys at boot.

### CFG-09 — `config/data/locations.json` inconsistencies (Low)

Only one entry carries `force_pickup_location_id`; the rest fall back to `id`. `monitored_reading_room` is present on a subset. There is no schema/validation, and the Ansible role copies this file into the backend's `config/data` volume (`deploy.yml`), so a typo silently changes library service rules.

**Suggestion.** Add a JSON schema + a spec that validates the file, and make the optional keys explicit.

### CFG-10 — `config/initializers/status_codes.rb` shape (Low)

`ResponseCodes`/`ErrorCodes` as modules of nested hashes, consumed via `const_get` (BE-25). `ResponseCodes::SUCCESS/FAIL` are defined but unused.

**Suggestion.** Replace with a small `Error` value object (`Error.new(code:, status:, message:)`) and a frozen lookup hash.

### CFG-11 — Development environment quirks (Low)

`config/environments/development.rb`: `config.hosts = [/.*/]`, `config.server_timing = true`, `config.action_mailer.raise_delivery_errors = false` (mailer is dead code anyway), a commented-out `EventedFileUpdateChecker` workaround, and a `caching-dev.txt` file-existence hack for `cache_store`.

### CFG-12 — `config.ru` / `Rakefile` / `puma.rb` (Low)

Standard, but `puma.rb` reads `PORT` (default 3000) while Compose passes `RAILS_PORT` (`docker/docker-compose.yml:57`) — the Rails server command in the Compose file (`rails server -b 0.0.0.0`) uses `-p` from `RAILS_PORT`? It does not: the command is `bundle exec rails server -b 0.0.0.0` with no `-p`, so `RAILS_PORT` only affects the _host_ side of the port mapping and silently assumes the container listens on 3000. If `RAILS_PORT` is changed, the mapping breaks.

**Suggestion.** Either hard-code 3000 in both places or pass `-p ${RAILS_PORT}`.

### CFG-13 — `config/environment.rb` + initializer ordering (Low)

`load_config.rb` runs at boot and reads files from disk; combined with `autoload_lib(ignore: %w(assets tasks))` and `lib/capistrano` (not ignored), a stray file under `lib/` becomes an eager-load failure in production.

### CFG-14 — No CSP actually applied (Low)

`config/initializers/content_security_policy.rb` exists but the app returns JSON; the frontend (Nitro) sets no CSP headers at all. Given SEC-12 (`v-html`), a CSP on the frontend would be a valuable mitigation.

---

## 11. Tests & specs

### TEST-01 — The suite very likely cannot boot (Critical)

`spec/rails_helper.rb:25` calls `ActiveRecord::Migration.maintain_test_schema!` but there is **no `config/database.yml`** and no database in the app. With `rspec-rails 3.9.1` on Rails 7.2 (DEP-01) and `shoulda-matchers 4.5` (DEP-02), `bundle exec rspec` is expected to fail before running a single example.

**Suggestion.** Remove the ActiveRecord line and `use_transactional_fixtures`/`fixture_path`, upgrade rspec-rails, and add a CI job that runs the suite.

### TEST-02 — Specs reference code that does not exist (High)

- `spec/models/access_token_spec.rb` — there is **no `AccessToken` model** in `app/models/` (the only reference in app code is the commented-out line at `reserves_controller.rb:86`).
- `spec/controllers/api/session_controller_spec.rb` — there is **no `Api::SessionController`** (BE-22).

These are relics of an older authentication design (file-based tokens in `tmp/`). Their presence suggests the current header-based auth (SEC-01) replaced a token system without restoring the token verification.

### TEST-03 — `Item` spec uses the wrong constructor keyword (High)

`spec/models/item_spec.rb` builds `Item.new(biblio_id: 1, xml: '…')` while `Item#initialize` accepts `biblio_id:, rawdata:, has_item_level_queue:` (`item.rb:10`) → `ArgumentError: unknown keyword: :xml`.

### TEST-04 — WebMock policy is inverted (Medium)

`spec/rails_helper.rb:39-45`: `WebMock.disable_net_connect!` **before each** example and `WebMock.allow_net_connect!` **after each** — leaving the global state permissive between suites and, more importantly, allowing accidental live calls to Koha/Libris if a stub is missing.

**Suggestion.** `WebMock.disable_net_connect!(allow_localhost: true)` once in a `before(:suite)`, and never re-enable it.

### TEST-05 — Factories are placeholders (Medium)

`spec/factories/{items,locations,sublocations}.rb` are ~6 lines each and mostly unused; the models' real complexity (Koha XML parsing) is exercised only through fixture XML in `spec/support/biblio/` and `spec/support/cas/`.

### TEST-06 — No coverage of the riskiest code (High)

No specs exist for `Api::CacheController`, `Api::LibrisController`, `Api::PickupLocationsController`, `Koha`, `Print`, `Subscription`, `Subscriptiongroup`, and none for the caching/mutation bug (BE-01), the loan-type/pickup filtering rules, or the order error paths (BE-02/03). Controller specs use `type: :controller`, deprecated in modern rspec-rails in favour of request specs.

**Suggestion.** Prioritise request specs for `POST /api/reserves` (success, Koha 4xx, transport failure), `GET /api/biblios/:id` (each record type, redirect, forbidden), and unit specs for `LoanType.where`/`Location.where` idempotency.

### TEST-07 — No frontend tests at all (High)

See FEA-04.

### TEST-08 — No CI configuration (High)

There is no `.github/workflows`, `.gitlab-ci.yml` or equivalent in the repository: no lint, no test run, no image build verification, no `ansible-playbook --check`. Deployment is driven by `ansible/run-playbook.sh` and `docker/build/tag_build_push.sh` manually.

---

## 12. Deployment (Docker, Compose, Ansible, Apache)

### DEPLOY-01 — Apache image is Ubuntu 14.04 (Critical)

`docker/build/apache/Dockerfile:1` — `FROM ubuntu:14.04` (standard support ended April 2019). This container terminates TLS for public hostnames and proxies to the backend. It is tagged `release-2021.10.001` in `docker/.env:2` and `ansible/host_vars/dev/vars.yml`.

It also runs `apachectl -DFOREGROUND -e debug` (debug log level in production) and `a2enmod autoindex`, which is what makes the `+Indexes` exposure in SEC-06 possible.

**Suggestion.** Rebuild on a supported Apache image (e.g. `httpd:2.4` or a current Ubuntu LTS), drop `autoindex`, use `-e info`, and pin by digest. Treat this as the single most urgent infrastructure task.

### DEPLOY-02 — Compose variables that Ansible never defines (High)

`docker/docker-compose.release.yml:11-20` uses `${BACKEND_DATA_HOST_DIR}`, `${FILES_HOST_DIR}`, `${BESTALL_APACHE_SITES_DIR}`, `${FILES_DIR}`. The Ansible role writes `.env` from `ansible/vars/default_env.yml`, which defines only `BACKEND_DATA_HOST_DIR`, `APACHE_SITES_HOST_DIR`, `FILES_HOST_DIR` (verified by grep: `BESTALL_APACHE_SITES_DIR` and `FILES_DIR` appear nowhere in `ansible/`). Locally they exist in `docker/.env:78-82`, which masks the problem.

An empty variable in a Compose volume spec yields `:/var/www/bestall/files` (an anonymous volume) — the files share silently stops being the host directory, so printed slips disappear and the Apache `/files` share is empty.

**Suggestion.** Unify the names (prefer `FILES_HOST_DIR`/`APACHE_SITES_HOST_DIR`/`BACKEND_DATA_HOST_DIR`), add `:?required` markers (`${FILES_DIR:?set}`), and add a `docker compose config` validation step in CI.

Related in the same file set:

- `docker/.env:9` sets `APACHE_HOST_PORT=` (empty) and `:10` `OMUTSKRIFT_HOST_PORT=` (empty, redefined later at `:85`) — an empty host-port variable yields a mapping of `:80`, i.e. bound on **all interfaces** rather than the loopback prefix the Ansible vars use.
- `docker/.env:7` `FRONTEND_HOST_PORT=6050` has no `127.0.0.1:` prefix (unlike `ansible/vars/default_env.yml`), so the frontend port is exposed on every interface of the dev machine.
- `docker/docker-compose.yml:57` passes `RAILS_PORT` to the container but the command (`bundle exec rails server -b 0.0.0.0`, line 58) never uses `-p`, so the app always listens on 3000 while `${BACKEND_HOST_PORT}:${RAILS_PORT}` maps to whatever `RAILS_PORT` says — changing it breaks the mapping.
- `docker/docker-compose.yml:12-13` reference `${NUXT_MYLOANS_URL}` / `${NUXT_DATE_FORMAT}`, which are not defined in `docker/.env` nor in any `ansible/vars/**`, so those public config values are always empty.

### DEPLOY-03 — Apache proxies to `localhost` inside its own container (High)

`ansible/templates/sites/bestall.conf.j2:30-51` and `sites/bestall-server.conf.j2:11` proxy to `http://localhost:<backend_host_port>` / `http://localhost:<apache_host_port>/files` (the latter is a self-proxy loop). But in `docker/docker-compose.yml` only `frontend` and `backend` join the `backend` bridge network — the `apache` service in `docker-compose.release.yml:13-20` declares **no network at all** and no `network_mode: host`. Inside the Apache container, `localhost` is itself, and the published ports are bound on the _host_ (`127.0.0.1:<port>` per `ansible/vars/default_env.yml`), so no proxy target is reachable from that container as configured.

**Suggestion.** Put `apache` on the same network and use service names (`http://backend:3000/api/...`), or run it with `network_mode: host`; add a post-deploy smoke test that `curl`s every proxied path.

### DEPLOY-04 — Frontend container port mismatch (High)

`docker/build/frontend/Dockerfile:22-26` sets `ENV NUXT_HOST=0.0.0.0`, `ENV NUXT_PORT=5000`, `EXPOSE 5000`, but `docker-compose.release.yml:5` maps `${FRONTEND_HOST_PORT}:3000`. Unless `NUXT_PORT` is overridden (it is not, in any Compose file or Ansible var), the mapped container port has nothing listening.

**Suggestion.** Remove `NUXT_PORT` from the image (let Compose decide) or map to 5000 consistently; add a healthcheck.

### DEPLOY-05 — `RAILS_ENV` never set by Ansible (High)

Related to CFG-01: `docker-compose.yml:55` uses `${ENVIRONMENT}`, which is `production` everywhere. There is no `RAILS_ENV` anywhere in `ansible/`.

### DEPLOY-06 — Backend image builds by cloning the repository at build time (Medium)

`docker/build/backend/Dockerfile:5-11` and `frontend/Dockerfile:4-15` `git clone $GIT_REPO_URL release -b $GIT_REVISION` inside the build. Consequences: unquoted variables (a `GIT_REVISION` containing spaces/flags alters the git command), no build reproducibility from a local working tree, cache-busting on every clone, and secrets in the build context are unnecessary.

**Suggestion.** `COPY . .` from the CI checkout, or clone in CI and pass an artifact; quote all variables; pin base images by digest.

### DEPLOY-07 — `bundle install` / `npm install` in production images (Medium)

Backend: `RUN bundle install` (no `--without development:test --deployment`, no `bundle config set frozen`). Frontend: `npm install` instead of `npm ci`. Dev/test gems (byebug, rspec-rails, webmock) end up in the production image, and builds are not reproducible.

### DEPLOY-08 — Containers run as root, no healthchecks, no read-only FS (Medium)

All four service Dockerfiles omit `USER` and `HEALTHCHECK`; Compose has no `read_only:`/`security_opt:`/`cap_drop:`. The Rails container writes to `/opt/bestall-files` and `tmp/`, the frontend needs nothing writable.

### DEPLOY-09 — Apache configuration hardening gaps (High)

`ansible/templates/sites/bestall.conf.j2` and `sites/bestall-server.conf.j2`:

- No security headers (HSTS, `X-Content-Type-Options`, `X-Frame-Options`, CSP, `Referrer-Policy`).
- `SSLCertificateChainFile` is deprecated since Apache 2.4.8 (use `SSLCertificateChainFile`→ full-chain file); no `SSLProtocol`/`SSLCipherSuite`/`SSLHonorCipherOrder` directives, so the defaults of an EOL distro apply.
- `FallbackResource /index.html` on the **backend** vhost (`bestall-server.conf.j2:8`) is meaningless for a JSON API and can mask 404s.
- `ProxyPassReverse` for `/print_bestall` and its sub-paths is defined four times with overlapping prefixes — order-dependent and easy to break.
- `.htpasswd` is copied by the role without an explicit mode.
- `ProxyPreserveHost Off` combined with unset `config.hosts` (CFG-02).

### DEPLOY-10 — `docker/.env` committed with environment specifics (Medium)

See SEC-16. It also contains syntax that Compose will not parse as intended:

- `RAILS_PORT=3000 # Neeed, or hard code in docker compose?` — inline comment (and a typo).
- Lines 55-58 use **colons** instead of equals (`NUXT_PUBLIC_MYLOANS_URL_SV: "https://…"`), so those four variables are not set at all — the frontend then falls back to the defaults in `nuxt.config.ts`.
- `NUXT_PUBLIC_GU_CLIENT_ID=` (line 76) is empty here and set per-host in Ansible — the precedence is easy to get wrong.

### DEPLOY-11 — `NUXT_LOCAL_OAUTH_ISSUER` vs `NUXT_LOCAL_O_AUTH_ISSUER` (Medium)

`docker/.env:38` sets `NUXT_LOCAL_OAUTH_ISSUER` (correct for the `localOAuthIssuer` key in `nuxt.config.ts:8`), but `docker/docker-compose.override.yml:11` sets `NUXT_LOCAL_O_AUTH_ISSUER`. Nitro derives different config keys from those two names, so the local mock-OIDC provider is enabled in one setup and silently disabled in the other.

### DEPLOY-12 — Ansible inventory/role wiring (Medium)

- `ansible/inventory/` contains `dev.yml`, `lab.yml`, `staging.yml` but **no `production.yml`**, while `run-playbook.sh:9` lists `production` as a valid target — a production deploy fails at inventory lookup.
- `run-playbook.sh:4-5` documents `<target> <playbook>` while `ansible/README.md` Deployment section says `./run-playbook.sh <host> deploy` and the file's own footer says `<playbook> <host>` — three different orders in one repo.
- `run-playbook.sh:28` reads the vault password from `~/.config/ub-ansible-deploy/.vault_password`, while the README instructs storing it as `ansible/.vault_password`.
- `run-playbook.sh:27` `set -x` prints every ansible argument (including any `--extra-vars` secrets).
- `host_vars/dev/vars.yml:2` sets `docker_git_revision: ansible-deploy-nuxt` — a branch name used as an image tag.
- `vars/dev/env.yml` points every printer (`PR40…PR62`, `PRINTER_TEST`) at the same IP — dev printing is a black hole; `docker/.env:96` even maps `PR47` to `file:/dev/null`.

### DEPLOY-13 — Compose has no resource limits or restart backoff (Low)

`restart: always` on all services with no `mem_limit`/`cpus` and no health-based restart policy; a leaking Rails process will be restarted forever without alerting anyone (ARC-11).

---

## 13. Documentation

### DOC-01 — Root `README.md` is stale and partly wrong (Medium)

- Instructs `rake db:migrate` — the app has no database, no migrations, no `config/database.yml`.
- Instructs `bower install` — a tool discontinued in 2017; the frontend is Nuxt/npm.
- "IMPORTANT FOR MAC M1" tells the reader to comment out `config.file_watcher = ActiveSupport::EventedFileUpdateChecker` in `config/environments/development.rb`, a line that no longer exists there.
- The bulk of the file is old Jira stories (KOHA-110, KOHA-144, KOHA-18) describing item-import behaviour that is not implemented in this repository.
- Section headings ("Ruby version", "System dependencies", "How to run the test suite") are placeholders.

**Suggestion.** Rewrite: architecture diagram (Nuxt → Nitro proxy → Rails → Koha), required env vars (both `NUXT_*` and `BESTALL_*`), how to run the stack with Docker Compose, how to run specs (once TEST-01 is fixed), how to deploy per stage, and where secrets live.

### DOC-02 — Frontend README is the untouched Nuxt starter (Low)

`frontend/README.md` is "Nuxt Minimal Starter" plus a locally added OAuth section, and its Production section has mismatched code fences (a ` ```bash ` block inside a 4-backtick fence).

### DOC-03 — Ansible README inconsistencies (Medium)

Typos (`reinstalltion`, `specic`, `<file-name>,j2`), the `run-playbook.sh` argument-order contradiction (DEPLOY-12), and no mention that `production` inventory is missing or that `ENVIRONMENT` is hard-coded to `production`.

### DOC-04 — Inline comments that mislead (Medium)

- `server/api/loantypes.ts:18` / `locations.ts:25`: "The query parameter is only used as a fallback if the session user data is not available" — in fact the backend trusts the client-supplied object completely (SEC-03).
- `nuxt.config.ts:95`: `escapeHtml: false, // how to make it secure ask Stefan` — an unresolved security question shipped in production code.
- `app/controllers/api/reserves_controller.rb:84-91`: commented-out authorization check with "Do we need this?".
- `app/controllers/api/print_controller.rb:53`: `# TBD Check other mandatory fields`.
- `app/models/item.rb:41,52`: `# TODO Extend with more rules` on the two most business-critical predicates.

**Suggestion.** Every `TBD`/`TODO` that describes a missing security control should become a tracked issue with an owner, not a comment.

### DOC-05 — No API documentation (Medium)

There is no description of the endpoints, the error envelope, or the `current-username` contract, even though the frontend and the Koha integration both depend on it. `config/routes.rb` is the only specification, and it is wrong (BE-22, CT-07).

**Suggestion.** Add an OpenAPI document (even hand-written) covering `/api/biblios/:id`, `/api/pickup_locations`, `/api/loan_types`, `/api/reserves`, `/api/print`, `/api/cache/clear`, and generate the frontend types from it (fixes CT-03, CT-04, CT-06).

---

## 14. Suggested remediation roadmap

### P0 — do first (security exposure + broken core paths)

1. **SEC-01 / SEC-02 / SEC-03** — replace the `current-username` header with a verified token, lock CORS down, and re-validate loan type + pickup branch + user eligibility server-side in `ReservesController#create`.
2. **SEC-06 / DEPLOY-01** — remove `+Indexes` and the unauthenticated `:80` `/files` vhost; rebuild the Apache image on a supported base.
3. **SEC-04 / FE-12** — fix the `force` truthiness bug (one-line change, restores an authorization check).
4. **SEC-05** — use the session's cardnumber in `currentuser.get.ts`.
5. **BE-01** — stop mutating cached `Location` objects (one-line `dup` at minimum, plus a regression spec).
6. **BE-02 / BE-03** — make order failures impossible to report as success.
7. **DEPLOY-02 / DEPLOY-03 / DEPLOY-04 / DEPLOY-05** — fix Compose variable names, the Apache `localhost` proxy, the frontend port mapping, and per-stage `RAILS_ENV`.

### P1 — correctness and reliability

8. **FE-01** — return `filteredExtendedLoanTypes`, fix/remove `isLoantypeDisabled`, declare the three runtime-config keys.
9. **FE-02, FE-03, FE-04, FE-05, FE-07, FE-08** — array state handling, unreachable `collection` branch, `error.response` guards, query-param JSON parsing, GitHub `xaccount`, auth middleware `loading` state.
10. **BE-04 … BE-08, BE-16** — nil/type-safety bugs in `ReservesController`, `Biblio.queue_level`, `Item#lost?`, `Item#in_transit?`, `has_borrowed_item?`.
11. **ARC-01 / ARC-02 / FE-21** — timeouts, retries, caching, and a health endpoint.
12. **SEC-09 / BE-23** — remove all `pp`/`console.log` payload dumps; expand `filter_parameter_logging`; set lab/staging log level to `info`.

### P2 — make the codebase testable and maintainable

13. **TEST-01 / DEP-01 / DEP-02** — get `rspec` running again; delete the dead `access_token_spec`/`session_controller_spec` or restore the token model they describe.
14. **FEA-04 / TEST-07 / TEST-08** — add `vue-tsc`, ESLint, Vitest, and CI (backend specs + frontend typecheck + `docker compose config` + `ansible-playbook -C`).
15. **DEP-03 / DEP-04 / DEP-05** — Puma 6, Prawn 2, replace `rest-client`.
16. **CFG-07 / FE-20 / BE-24** — delete dead Rails views/assets/helpers/mailers/helpers, dead Vue components, `test.vue`/`docs` routes, unused gems and `xml2js`.
17. **CT-01 … CT-08** — one API contract, one error envelope, generated frontend types.

### P3 — polish

18. **I18N-01 … I18N-06** — missing keys, `escapeHtml: true`, `lang` attribute, localised print slips.
19. **CFG-05 / CFG-06 / CFG-10 / CFG-12** — Rails initializer cleanup.
20. **DOC-01 … DOC-05** — rewrite the READMEs and add an OpenAPI spec.

---

## 15. Verification notes & assumptions

- All findings are from static reading; nothing was executed, so runtime-only behaviour (e.g. whether the `ub-ansible-deploy` role post-processes `.env` names, or whether the external `docker.ub.gu.se/rails:ruby-3.2.2` base image sets `RAILS_ENV`/`USER`/`WORKDIR` conventions) could soften **DEPLOY-02**, **DEPLOY-03**, **DEPLOY-04** and **DEPLOY-05**. Each is still worth confirming explicitly, because the repository as committed does not provide those values.
- Component "unused" conclusions were derived from a Nuxt auto-import-aware scan (`<ComponentName>` for both top-level and nested `components/<dir>/<name>.vue` names); `Header.vue`, `BaseModal.vue`, `OrderDenied.vue`, `icons/info.vue` and the `docs/*` style-guide components have no references.
- i18n key analysis was done programmatically: `en.json` and `sv.json` each contain 143 leaf keys with no key missing from either file; exactly one statically referenced key (`viewType.collection.copies`) is undefined in both; the `orderDenied.errors.*` family is referenced dynamically and is incomplete (I18N-02).
- Version claims were taken from `Gemfile.lock` (rails 7.2.1, puma 3.12.6, prawn 1.3.0, rspec-rails 3.9.1, rack 3.1.8, `BUNDLED WITH 2.4.10`) and `frontend/package.json` (nuxt ^4.4.5, @nuxtjs/i18n ^10.3.0, @sidebase/nuxt-auth ^1.2.0, next-auth ^4.21.1).
