# Git Lab 02 – soli pa solim (ceļvedis latviski)

> **Svarīgi:** šajā repozitorijā laboratorijas darbs jau ir **izpildīts** (zars `release-plan`,
> žurnāls `INTEGRATION_LOG.md`). Tavs Gitea repo (`grade-calculator-practice/`) ir veidots ar
> pasniedzēja skriptu, tāpēc koda saturs un konflikti tur var nedaudz atšķirties.
> **Komandas un secība ir tās pašas** — konfliktus atrisini pēc tās pašas loģikas, kas aprakstīta zemāk.
> Ja tev pasniedzēja skripta nav, vari izmantot `./create_grade_calculator_repo.sh`.

Visur, kur redzi `<...>`, ieliec savu vērtību (piem., commit hash no `git log`).

---

## 1. solis – Sagatavo repo

```bash
cd ~/grade-calculator-practice        # vai kur tev ir repo (atbilde uz 1. jautājumu: `pwd`)
git --version                          # atbilde uz 2. jautājumu
git fetch --all
git branch -a                          # pārbaudi, ka ir visi 5 zari (3. jautājums)
git checkout dev
git status                             # jābūt "working tree clean"
```

Jābūt zariem: `feature/strict-grading`, `feature/weighted-average`, `feature/detailed-output`,
`feature/plus-minus-grades`, `fix/rounding-bug`.
Ja kāds zars ir tikai `remotes/origin/...`, izveido lokālo: `git checkout -b feature/x origin/feature/x`.

## 2. solis – Izpēti (auditē) katru zaru

Katram zaram izpildi:

```bash
git log --oneline --graph dev..feature/weighted-average     # kādi commiti
git diff --stat dev...feature/weighted-average              # kuri faili mainās
git diff dev...feature/weighted-average                     # paši labojumi
git checkout feature/weighted-average && python grade_calculator.py && git checkout dev
```

Atkārto ar `feature/detailed-output`, `feature/strict-grading`, `feature/plus-minus-grades`,
`fix/rounding-bug`. Katram pieraksti: **mērķis, izmaiņas, riski, verdikts (ship/review/reject)**.

Ko es atradu (salīdzini ar savējo):

| Zars | Ko dara | Problēma | Verdikts |
|---|---|---|---|
| weighted-average | svērtais vidējais (gala eksāmens 35%) | nav | ship – merge |
| detailed-output | tabula ar min/max | cits koda stils, konflikts `main()` | ship – merge |
| fix/rounding-bug | `int()` → `round()` | 2. commits ir DEBUG print | ņem tikai 1. commitu |
| strict-grading | stingrāka skala + validācija | `ValueError: invalid score: 100` | reject – merge + revert |
| plus-minus-grades | B+, B- atzīmes | konflikts virsrakstā | rebase |

## 3. solis – Izveido `release-plan` un pieraksti plānu

```bash
git checkout dev
git checkout -b release-plan
# izveido INTEGRATION_LOG.md ar auditu + plānu (vari ņemt manējo par paraugu)
git add INTEGRATION_LOG.md
git commit -m "docs: record branch audit and integration plan for release-plan"
```

Plāns: 1) weighted → 2) detailed → 3) rounding (cherry-pick) → 4) strict (merge + revert) → 5) plus-minus (rebase).

## 4. un 5. solis – Merge, rebase, revert + pārbaude pēc katra soļa

### 4.1 Merge `feature/weighted-average` (bez konflikta)

```bash
git merge --no-ff feature/weighted-average
# atvērsies redaktors – uzraksti jēgpilnu ziņu, piem.:
#   merge: integrate feature/weighted-average into release-plan
#   Merged first because every other branch uses the average it computes.
python grade_calculator.py        # PĀRBAUDE: jāstrādā bez kļūdām
```

`--no-ff` vienmēr izveido merge commitu → vēsturē redzams, ka tika integrēts zars, un to var atsaukt vienā gabalā.

### 4.2 Merge `feature/detailed-output` (BŪS konflikts)

```bash
git merge --no-ff feature/detailed-output
git status                        # grade_calculator.py: "both modified"
```

Atver failu un atrodi:

```
<<<<<<< HEAD
        ...tava release-plan versija (weighted average)...
=======
        ...detailed-output versija (tabula)...
>>>>>>> feature/detailed-output
```

**Kā atrisināt:** atstāj *abus* uzlabojumus — `calculate_weighted_average(scores, WEIGHTS)` no HEAD
**un** jauno `format_report(name, scores, average, grade)` + tabulas virsrakstu/kājeni no otra zara.
Izdzēs visas `<<<<<<<`, `=======`, `>>>>>>>` rindas.

```bash
grep -n "<<<<<<<\|>>>>>>>" grade_calculator.py   # jābūt tukšam
python grade_calculator.py                        # PĀRBAUDE
git add grade_calculator.py
git commit                                        # apraksti konfliktu un kā to atrisināji
```

### 4.3 `fix/rounding-bug` – cherry-pick -n + restore (atsaukšanas demonstrācija)

```bash
git log --oneline dev..fix/rounding-bug          # 2 commiti: fix + debug
git cherry-pick -n fix/rounding-bug              # uzliek DEBUG commitu, BET necommito
python grade_calculator.py                        # redzi DEBUG rindas → nevēlams
git restore --source=HEAD --staged --worktree grade_calculator.py   # izmet izmaiņas
git cherry-pick --quit                            # notīra cherry-pick stāvokli (ja vajag)
git status                                        # jābūt tīram

git cherry-pick -x fix/rounding-bug~1            # tagad tikai īstais labojums
# ja konflikts: atstāj weighted + tabulu, bet nomaini int(average) → round(average, 1)
git add grade_calculator.py
git cherry-pick --continue
python grade_calculator.py                        # PĀRBAUDE: 80.0 tagad ir B, nevis C
```

### 4.4 `feature/strict-grading` – slikts merge un `git revert`

```bash
git merge --no-ff feature/strict-grading
# konflikts: atstāj abas funkcijas (calculate_weighted_average UN validate_scores),
# ciklā izsauc validate_scores(scores) pirms vidējā aprēķina
git add grade_calculator.py
git commit                                        # "merge: trial integration of feature/strict-grading ..."
python grade_calculator.py                        # ✗ ValueError: invalid score: 100
```

Kļūda: `0 <= score < 100` neļauj 100 punktus. Atsauc merge:

```bash
git log --oneline -3                              # atrodi merge commita hash
git revert -m 1 <merge-hash>                      # -m 1 = paturēt release-plan pusi
# ziņā paskaidro: kāpēc atsauc, kāda bija kļūda
python grade_calculator.py                        # PĀRBAUDE: atkal strādā
git diff HEAD~2 HEAD                              # tukšs = viss atjaunots precīzi
```

`git revert` neizdzēš vēsturi, bet pievieno jaunu commitu, kas atceļ izmaiņas — tas ir drošs arī jau push'otiem zariem.
(`git reset --hard` der tikai lokāliem, vēl nepush'otiem eksperimentiem.)

### 4.5 `feature/plus-minus-grades` – rebase

```bash
git checkout feature/plus-minus-grades
git rebase release-plan
# konflikts virsrakstā: atstāj jauno tabulas virsrakstu un pievieno rindu
#   print("Scale: A/B/C/D with +/- modifiers, F has no modifier")
git add grade_calculator.py
git rebase --continue
python grade_calculator.py                        # PĀRBAUDE: B+, C-, A- ...

git checkout release-plan
git merge --ff-only feature/plus-minus-grades     # lineāra vēsture, bez merge commita
python grade_calculator.py                        # gala PĀRBAUDE
```

Rebase pārraksta zara commitus (jauni hash) — to dara tikai ar zariem, ko neviens cits vēl nelieto.

Ja kaut kas noiet greizi: `git merge --abort`, `git rebase --abort`, `git cherry-pick --abort`.

## 6. solis – Pabeigšana un iesniegšana

```bash
git log --oneline --graph dev..release-plan       # vai vēsture stāsta skaidru stāstu?
# papildini INTEGRATION_LOG.md ar to, kas notika (konflikti, pārbaudes rezultāti)
git add INTEGRATION_LOG.md
git commit -m "feat: complete Git Lab 02 - Branch integration and conflict resolution"

git push -u origin release-plan                   # Gandalf pārbauda šo zaru
git push -u origin dev                            # kā prasīts uzdevumā
```

**NEDARI** `git merge release-plan` iekš `main` — recenzenti paši izčeko `release-plan`.

Pārbaude pirms iesniegšanas:

```bash
git branch -a | grep release-plan                 # zars ir arī origin
git log --merges --oneline dev..release-plan      # redzami merge commiti
python grade_calculator.py                        # strādā bez kļūdām
```
