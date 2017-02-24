# README

## Allmänt

- Ruby version
- System dependencies
- Configuration
- Database creation
- Database initialization
- How to run the test suite
- Services (job queues, cache servers, search engines, etc.)
- Deployment instructions


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

2. Hemlån ska vara default-val.

#### KOHA-19 Välja avhämtningsställe
Användaren ska kunna välja vilket bibliotek som hen vill hämta sin beställda bok på, dvs. avhämtningsställe.

Acceptanskriterier:
1. Kunna välja bibliotek från en lista på alla bibliotek.

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
- ej utlånade:
- ej exemplarstatus, tex Lost, Restricted use =3,4,5,6 (dvs Läslust Gp, Läslust Gm, Konstbibl och Mod)

Köbara exemplar:
- ej item type: ref,
- ej materialkategori Läslust Gm och exemplarstatus Läslust Gp

#### KOHA-230 Möjlighet att redigera beställningen via bekräftelsesidan ytterligare

1. Det ska vara möjligt att ändra exemplar innan bekräftelsen är godkänd.



## Acceptanstester
Testerna bygger på acceptanskriterier som redan de lämpligen är formulerade som påståenden som antingen kan bekräftas eller förkastas. Tillsammans beskriver de det tillstånd som systemet befinner sig i när acceptans uppnåts. För att det ska vara någon mening med det måste man ha en möjlighet att kontrollera utfallet, dvs, ett kriterium måste vara *testbart*.

| Acceptanskriterium | Test ( *verifiera att...* ) | PASS |
| :---        | :------------ |:---:|
| KOHA-110-1  | Det finns en exemplarpost i Koha baserat på innehållet i 949. |    |
| KOHA-110-2  | 949$z har lagts till i bibposten så att inte dubbletter skapas. |    |
| KOHA-110-3  | Det skapas ingen ny exemplarpost om streckkoden redan finns. |    |
| KOHA-110-4  | Det skapas ingen ny expost om det redan finns en post med den lokaliseringskod som står i inkommande 949 $D. |    |
| KOHA-110-5  | Det skapas ingen ny expost om 949 $z finns i bibposten. |    |
| KOHA-144-1 | Inkommande post som innehåller decomposed utf-8 omvandlas till precomosed utf-8. |     |
| KOHA-18-1 | Användaren ska kunna logga in med sin CAS. |     |
| KOHA-18-2 | Om användaren redan har loggat in så hoppas steget över enligt Single-sign-on-principen. |     |
| KOHA-203-1 | Användaren har möjlighet att välja ett av följande värden: Hemlån, Läsesal, Forskarskåp eller Institutionslån |  |
| KOHA-203-2 | Hemlån är default-val |  |
| KOHA-19-1 | Man kan välja bibliotek från en lista på alla bibliotek |    |
| KOHA-223-1 | Exemplar kan väljas före avhämtningställe. |  |
| KOHA-223-2 | Alla exemplar listas. |  |
| KOHA-223-3 | Det är tydligt vilka exemplar som går att beställa och inte. |  |
| KOHA-223-4 | Det är tydligt vilka exemplar som är utlånade |  |
| KOHA-223-5 | Designfråga! |  |
| KOHA-230-1 | Det är möjligt att ändra exemplar innan bekräftelsen är godkänd. |  |
| - | - | - |
