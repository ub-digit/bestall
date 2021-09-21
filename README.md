# README

## IMPORTANT FOR MAC M1

- Go to: config/environments/development.rb
- Comment this line out: config.file_watcher = ActiveSupport::EventedFileUpdateChecker

## Allmänt

- Ruby version
- System dependencies
- Configuration
- Database creation
- Database initialization
- How to run the test suite
- Services (job queues, cache servers, search engines, etc.)
- Deployment instructions

## Starta utvecklingsmiljön

- ha ett ub-namn i hosts-filen som pekar på 127.0.0.1, t.ex: `127.0.0.1 bestall-dev.ub.gu.se`
- gör följande:

```bash
bundle install
rake db:migrate
cd frontend
npm install
bower install
cd ..
rails server
```

## Systembeskrivning

### Resurser

- Länkar till skisser, foton, databasdiagram etc.

### Stories som systemet uppfyller

#### KOHA-110 Skapa exemplarpost utifrån 949

Skapa exemplarpost och generera 949 $z vid import. Existerande exemplarposter måste skyddas. Inkommande nya exemplar ska läggas till och inte skapa dubbletter.

1. Det finns en exemplarpost i Koha baserat på innehållet i 949.
2. 949$z har lagts till i bibposten så att inte dubbletter skapas.
3. Det skapas ingen ny exemplarpost om streckkoden redan finns.
4. Det skapas ingen ny expost om det redan finns en post med den lokaliseringskod som står i inkommande 949 $D.
5. Det skapas ingen ny expost om 949 $z finns i bibposten.

#### KOHA-144 Ladda utf-8, prekomponerad

Olika utf8-kodningar behöver kunna tas emot. Vi vill kunna konvertera till Precomposed från Decomposed om det behövs.

1. Inkommande post som innehåller decomposed utf-8 ska omvandlas till precomosed utf-8.
   Helen kan ge exempel på post som det går att testa med.

#### KOHA-18 inloggning med CAS

Låntagarens ska kunna logga in i beställningsgränssnittet med sin CAS-inloggning.

Acceptanskriterier:

1. Användaren ska kunna logga in med sin CAS.
2. Om användaren redan har loggat in så hoppas steget över enligt Single sign on -principen.

#### KOHA-203 Välja typ av lån

Användaren ska ha möjlighet att välja typ av lån.

Acceptanskriterier:

1. Användaren ska ha möjlighet att välja ett av följande värden: Hemlån, Läsesal, Forskarskåp eller Institutionslån,
2. ~~Hemlån ska vara default-val.~~ (se KOHA-226)

#### KOHA-226 Regelverk för "Typ av lån"-val

Typ av lån avgör hur materialet får hanteras efter att det har hämtats. Alla materialtyper stödjer inte alla lånetyper, så det finns ett regelverk som måste följas.

Acceptanskriterier:

1. Alternativet hemlån ska döljas om materialkategorin är 8, 17.
2. Alternativet hemlån ska döljas om exemplarstatus är NOT_LOAN = -3.
3. Defaultval ska vara första valbara alternativ i listan

#### KOHA-19 Välja avhämtningsställe

Användaren ska kunna välja vilket bibliotek som hen vill hämta sin beställda bok på, dvs. avhämtningsställe.

Acceptanskriterier:

1. Kunna välja bibliotek från en lista på alla bibliotek.

#### KOHA-227 Regelverk för "Val av avhämtningsställe"

Med avhämtningsställe avses de bibliotek som beställningar kan hämtas på. Lista bifogas.

Acceptanskriterier:

1. Låntagare av typen FI, SY och FY kan välja alla bibliotek (se bifogad fil: lista_bibliotek) som avhämtningsställe.
2. Övriga låntagare kan inte välja exemplarets ägande bibliotek (home branch) för böcker på öppna hyllor (bifogad fil: öppna_hyllor).
3. Om ägande bibliotek är Gm så får Gm väljas av alla låntagare.
4. Alla låntagare får välja exemplarets ägande bibliotek när exemplaren står i slutna magasin (bifogad fil: slutna_magasin).

#### KOHA-233 Skapa kö i Koha

När bekräftelse skickas säg till Koha att skapa en kö.

Acceptanskriterium:

1. Det skapas en rad i reservestabellen med de uppgifter som angivits.

#### KOHA-223 Välja exemplar

Om det finns tillgängliga exemplar så ska användaren ska kunna välja vilket exemplar hen vill låna.

Acceptanskriterier:

1. Exemplar ska väljas före avhämtningställe.
2. Alla exemplar listas.
3. Det ska vara tydligt vilka exemplar som går att beställa och inte.
4. Det ska vara tydligt vilka exemplar som är utlånade
5. Beställningsbara exemplar ska visas överst i listan.

Med beställningsbara avses

- ej item type: ref,
- ej item type: kursbok
- ~~ej utlånade:~~ (se KOHA-364)
- ~~ej exemplarstatus, tex Lost, Restricted use =3,4,5,6 (dvs Läslust Gp, Läslust Gm, Konstbibl och Mod)~~ (se KOHA-364)

Köbara exemplar:

- ~~ej item type: ref,~~ (se KOHA-365)
- ~~ej materialkategori Läslust Gm och exemplarstatus Läslust Gp~~ (se KOHA-365)

#### KOHA-364 Utöka regelverk för beställningsbara exemplar

Acceptanskriterier:

1. ej exemplarstatus LOST (LOST != 0)
2. ej exemplarstatus RESTRICTED (!= 0)
3. ej reservation på exemplar
4. står på en hylla (loc code) som får beställas från (is_paging_loc)

#### KOHA-365 Lägg till regelverk för köbara exemplar

Acceptanskriterier:

1. Ej materialkategori REF (7)
2. Ej exemplarstatus RESTRICTED (1, 2, 5, 6)
3. Leader pos 7 är s eller c
4. Exemplaret har due date eller reservation

Leader pos 7 "s eller c" betyder att eventuell kö sker på exemplar.
Annat i leader innebär att kö sker på bib-post.

#### KOHA-230 Möjlighet att redigera beställningen via bekräftelsesidan ytterligare

Acceptanskriterier:

1. Det ska vara möjligt att ändra exemplar innan bekräftelsen är godkänd.

#### KOHA-280 Göm alla formulärfält i rutan i Manage staged file

Acceptanskriterier:

1. Alla dropdowns och knappen i rutan är gömda.
2. Allt t o m status ska vara kvar.

#### KOHA-285 Default att visa alla rader i Managed staged file

Default idag är att 20 rader visas.

Acceptanskriterier:

1. Default är Alla.

#### KOHA-284 Göm fält i Stage file

Göm ruta "Use MARC Modification Template" samt
"Look for existing records in catalog?" samt ev plugin. samt dropdown "How to process items:"

#### KOHA-203 Välja typ av lån

Användaren ska ha möjlighet att välja typ av lån.

Acceptanskriterier:

1. Användaren ska ha möjlighet att välja ett av följande värden: Hemlån, Läsesal, Forskarskåp eller Institutionslån,
2. Hemlån ska vara default-val.

#### KOHA-363 Visa felmeddelande när beställning/kö i Koha misslyckas.

Felmeddelande innan inloggning, enbart baserat på bibid (materialkategori=ref).

Acceptanskriterier:

1. Det ska informeras att fel inträffat.
2. Felmeddelande från Koha ska visas.

#### KOHA-227 Regelverk för "Val av avhämtningsställe"

Med avhämtningsställe avses de bibliotek som beställningar kan hämtas på. Lista bifogas.

Acceptanskriterier:

1. Låntagare av typen FI, SY och FY kan välja alla bibliotek (se bifogad fil: lista_bibliotek) som avhämtningsställe.
2. Övriga låntagare kan inte välja exemplarets ägande bibliotek (home branch) för böcker på öppna hyllor (bifogad fil: öppna_hyllor).
3. Om ägande bibliotek är Gm så får Gm väljas av alla låntagare.
4. Alla låntagare får välja exemplarets ägande bibliotek när exemplaren står i slutna magasin (bifogad fil: slutna_magasin).

#### KOHA-226 Regelverk för "Typ av lån"-val

Typ av lån avgör hur materialet får hanteras efter att det har hämtats. Alla materialtyper stödjer inte alla lånetyper, så det finns ett regelverk som måste följas.

Acceptanskriterier:

1. Alternativet hemlån ska döljas om materialkategorin är 8, 17.
2. Alternativet hemlån ska döljas om exemplarstatus är NOT_LOAN = -3.
3. Defaultval ska vara första valbara alternativ i listan

#### KOHA-356 Visa felmeddelande vid fel rörande bibliografisk post

Felmeddelande innan inloggning, enbart baserat på bibid (materialkategori=ref).

Acceptanskriterier:

1. Felmeddelande ska tala om att det inte går att beställa eller köa på någon del av bibposten

#### KOHA-357 Visning av bibliografisk post, se till att kö på bib och exemplar kommer med

Acceptanskriterier:

1. Exemplarlistan ska visa information om existerande kö, beställning och transport.
2. Sammanlagd siffra för antal i kö visas på bibnivå.

---

## Acceptanstester

Testerna bygger på acceptanskriterier som redan de lämpligen är formulerade som påståenden som antingen kan bekräftas eller förkastas. Tillsammans beskriver de det tillstånd som systemet befinner sig i när acceptans uppnåts. För att det ska vara någon mening med det måste man ha en möjlighet att kontrollera utfallet, dvs, ett kriterium måste vara _testbart_.

| Acceptanskriterium | Test ( _verifiera att..._ )                                                                                   | PASS |
| :----------------- | :------------------------------------------------------------------------------------------------------------ | :--: |
| KOHA-110-1         | Det finns en exemplarpost i Koha baserat på innehållet i 949.                                                 |      |
| KOHA-110-2         | 949$z har lagts till i bibposten så att inte dubbletter skapas.                                               |      |
| KOHA-110-3         | Det skapas ingen ny exemplarpost om streckkoden redan finns.                                                  |      |
| KOHA-110-4         | Det skapas ingen ny expost om det redan finns en post med den lokaliseringskod som står i inkommande 949 $D.  |      |
| KOHA-110-5         | Det skapas ingen ny expost om 949 $z finns i bibposten.                                                       |      |
| KOHA-144-1         | Inkommande post som innehåller decomposed utf-8 omvandlas till precomosed utf-8.                              |      |
| KOHA-18-1          | Användaren ska kunna logga in med sin CAS.                                                                    |      |
| KOHA-18-2          | Om användaren redan har loggat in så hoppas steget över enligt Single-sign-on-principen.                      |      |
| KOHA-203-1         | Användaren har möjlighet att välja ett av följande värden: Hemlån, Läsesal, Forskarskåp eller Institutionslån |      |
| KOHA-203-2         | Hemlån är default-val                                                                                         |      |
| KOHA-19-1          | Man kan välja bibliotek från en lista på alla bibliotek                                                       |      |
| KOHA-223-1         | Exemplar kan väljas före avhämtningställe.                                                                    |      |
| KOHA-223-2         | Alla exemplar listas.                                                                                         |      |
| KOHA-223-3         | Det är tydligt vilka exemplar som går att beställa och inte.                                                  |      |
| KOHA-223-4         | Det är tydligt vilka exemplar som är utlånade                                                                 |      |
| KOHA-223-5         | Designfråga!                                                                                                  |      |
| KOHA-230-1         | Det är möjligt att ändra exemplar innan bekräftelsen är godkänd.                                              |      |
| -                  | -                                                                                                             |  -   |
