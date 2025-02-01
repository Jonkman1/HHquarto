// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "linux libertine",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "linux libertine",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black or heading-decoration == "underline"
           or heading-background-color != none) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#show: doc => article(
  authors: (
    ( name: [Harrie Jonkman],
      affiliation: [],
      email: [] ),
    ),
  lang: "nl",
  toc: true,
  toc_title: [Inhoudsopgave],
  toc_depth: 2,
  cols: 1,
  doc,
)


#set page(
  paper: "a5",
  margin: (left: 2cm, right: 2cm, top: 2cm, bottom: 2cm),
  background: place(left + top, rect(
  fill: rgb("#f3e6c8"),
  height: 100%,
  width: 1.5cm,
))
)
#set text(
  font: "New Computer Modern",
  size: 11pt
)
#set par(
  justify: true,
  leading: 0.80em,
)
= #text(size: 24pt , fill: rgb("#cc6652"))[Richtlijnen voor de]
<richtlijnen-voor-de>
= #text(size: 24pt , fill: rgb("#cc6652"))[toekomst]
<toekomst>
\
\

#block[
#set text(size: 16pt , fill: gray); In #emph[De kracht van gras] bespreekt de filosoof Jan-Hendrik Bakker de dichtbundel #emph[Grasbladen] van 19e eeuwse Amerikaanse dichter Walt Whitman en wat zijn denken over de persoon, de samenleving en de kosmos voor onze tijd kan betekenen.

]
\

#emph[Het bijzonderste wat Amerika aan de geest en de wijsheid van de wereld heeft bijgedragen.] \
\- Ralf Waldo Emerson

\
\

== #text(size: 14pt , fill: rgb("#cc6652"))[De kracht van gras]
<de-kracht-van-gras>
Walt Whitman, zo schrijft Jan-Hendrik Bakker in zijn boek #emph[De Kracht van gras. Walt Whitman en onze tijd];, is een van de mensen geweest die Amerika z’n identiteit heeft gegeven @bakker-a. Zoals Bob Dylan dat een eeuw later zal doen, zeg maar. Whitman (1819-1892) doet dat met z’n dichtbundel #emph[Leaves of Grass/Grasbladen] dat in 1855 verschijnt en waarin hij in een twaalftal gedichten zijn optimistische vergezicht op de mens, de wereld en de kosmos beschrijft. Er zullen een aantal uitgaven verschijnen en de laatste rondt hij af vlak voor zijn dood. Hij is een selfmade-genie, die op vroege leeftijd moet werken, timmerman is, leraar, journalist, verpleegkundiger en bovenal dichter natuurlijk. Hij is niet alleen van belang voor de Amerikaanse identiteit, hij is ook belangrijk voor de queergemeenschap, inspireert belangrijke dichters en denkers en zijn radicaal humanisme en universeel optimisme geeft mensen hoop op een een betere wereld. Voor de filosoof Bakker is Whitman interessant voor onze tijd waarin de democratie het moeilijk heeft en we niet goed weten welke democratie we nodig hebben. We hebben namelijk met elkaar niet een goed uitgewerkt idee van een gedeelde toekomst. Dat heeft Whitman in de 19e-eeuw wel. Het is goed zijn denken over humaniteit, individualiteit en hoop naar onze tijd te verplaatsen en te kijken naar wat de betekenis van hem nu is.

\
\

== #text(size: 14pt , fill: rgb("#cc6652"))[Humaniteit, individualiteit en hoop]
<humaniteit-individualiteit-en-hoop>
Sinds de Renaissance gaat de mens zichzelf als individu zien die deel uitmaakt van de kosmos. Zo ontstaat het idee van vrijheid en ontplooiing. De mens wordt zich bewust van de innerlijke beleving, het dagelijkse leven wordt gezien en de natuur ontdekt. In elk individu zit wel een vonkje goddelijk en zo wordt de wereld ook een mensenwereld die onze liefde verdient en waarin kritiek en verbeelding mogelijk worden. De mens maakt zich los uit het groter verband, maar zet zich ook op de troon en onderwerpt de wereld. De mens krijgt een opdracht omdat humaniteit daarom vraagt. Die opdracht ziet Whitman en voor hem zit het universele in het kleine en het onbeduidende in het moment. Voor hem zit het in de verbinding van het persoonlijke zelf met de zelven van anderen, de zelf die zich kan verplaatsen in de anderen en dat ook van anderen te vragen. Dat individuele, dat dagelijkse en het natuurlijke komen in zijn #emph[Grasbladen] terug. #emph["Lees deze bladen in de open lucht, elk seizoen, elk jaar van je leven"];. \
Voor Whitman gaat het nog om de verbinding van het individu met de massa. Daarvoor is het nodig je op een goede manier te verhouden tot de anderen. Het gaat hem om vreedzaam samenkomen (concreet en fysiek) van het individu met de anderen op openbare plekken zoals op de veerpont of aan het strand, waarin Whitman jou als ander en lezer op verschillende manieren betrekt en laat zien dat er in massaliteit individualiteit zit (#emph["Uit het rollen der oceaan, de massa, kwam een druppel zachtjes tot mij"];). Juist nu de individualiteit het zo moeilijk heeft in onze tijd (met z’n eenzaamheid, consumptie/verspilling/verlies sociale cohesie en de totalitaire macht van de media) is het van belang na te denken over hoe we de verschillen tussen mensen overeind kunnen houden. Kunst kan daar steun bieden en dat is precies wat Whitman wil. \
Om jezelf als persoon te zien, is het nodig jezelf te zien als iemand met een eigen geest. Je moet jezelf kunnen zien, jouw eigen gedachten en gevoelens herkennen en weten dat je in de tijd en de ruimte leeft. Kortom, er is een zelfbewustzijn nodig van ik besta, neem waar, denk en voel en ik leef in de wereld. Dat is nodig ook om voorstellingen te maken van anderen in andere omstandigheden en de wereld buiten jezelf. Taal (om jezelf en elkaar te begrijpen) is daarbij nodig evenals een verantwoordelijkheidsgevoel daarvoor nodig is. Met taal en dat verantwoordelijkheidsgevoel is er een betere wereld mogelijk en dat geeft hoop. De hoop op de betere wereld en daaraan werken drukt Whitman uit in democratie, dat voor hem vooral de verbondenheid tussen mensen uitdrukt. Democratie omvat voor hem veel meer dan verkiezingen en politieke en partij-beslommeringen. Het gaat hem om de omgang en de interactie tussen mensen en de manier waarop we overtuigingen delen met elkaar in het openbare en persoonlijke leven. Het gaat Whitman om de mens, zijn karakter en zijn persoonlijkheid en om de omgang met elkaar. De individuele mens ziet hij als bouwsteen voor de democratie en elke steen hebben we daarvoor nodig. Te veel wil Whitman er ook weer niet over kwijt, want hij wil zich niet opdringen. Dan trekt hij zich terug en laat het aan de toekomstige generatie over:

#quote(block: true)[
#emph[Wat mij aangaat; ik schrijf slechts een paar richtlijnen voor de toekomst. Ik doe slechts even en stap naar voren om me dan weer terug te haasten in de duisternis];.
]

\
\

== #text(size: 14pt , fill: rgb("#cc6652"))[Whitman als inspiratiebron]
<whitman-als-inspiratiebron>
Bakker heeft een mooi boek geschreven over #emph[Grasbladen] van Walt Whitman en daarin plaatst en bespreekt hij dit werk als filosoof. Aan de 19e -eeuwse tijd en context waarin Whitman opgroeit, besteedt Bakker betrekkelijk weinig aandacht. Voor mij had dit meer aandacht verdient. Bakker wisselt hoofdstuk over het poëziewerk Grasbladen af met hoofstukken over filosofische thema’s. Hij bespreekt die thema’s van de 19e -eeuwse Whitman vanuit de ooghoeken van 20ste/21ste-eeuwse filosofen. Meer nog dan het hoofdwerk zelf (waar hij terecht enorme bewondering voor heeft), lijkt het hem te gaan om de betekenis van dat werk voor onze tijd. Over integrale geletterdheid en burgerraden en dergelijke had Whitman het niet en daarmee wil ik maar flauw zeggen dat niet alles voortkomt uit het werk van Whitman. Bakker gebruikt Whitman vooral als inspiratiebron. Het gaat Bakker om de kracht van gras en hij wil dat het Whitmans poëziewerk stimulerend werkt op de kracht van de democratische samenleving en de progressieve politiek. \
Het is Richard Rorty, die vijfentwintig jaar geleden wijst op het humanistisch elan van de dichter Whitman en ook op het wetenschappelijke werk van zijn evenknie en de iets jongere John Dewey. Whitman en Dewey schrijven beiden op hun eigen manieren (de een met gevoel, de ander met theorie) veel over ervaring, communicatie, participatie en gemeenschap. Rorty ziet dat in de tijd van zijn pleidooi de sociaaleconomische strijd voor gelijkheid en sociale rechtvaardigheid en het werken aan een betere wereld worden ingeleverd voor cultuurpolitiek en getheoretiseer. Daarmee neemt links ten onrechte afstand van de erfenis van Whitman en Dewey. Bakker bouwt hierop voort. Allicht, zo denkt Bakker, kunnen we met Whitmans #emph[Grasbladen] zelf weer meer zachtaardig, eenvoudig, kritisch, tolerant en vrijgevig worden en tegelijk het vertrouwen terugkrijgen in de democratische samenleving. Gras staat symbool voor overleving, volharding, diversiteit, verbinding, groei en sterfelijkheid en het is iets alledaags en onuitroeibaar. Door #emph[Grasbladen] te bespreken, er de kracht van te laten zien en het in onze tijd te plaatsen stuurt Bakker ons naar een samenleving en een politiek waarin het om het individu, de persoon, de wereld en de kosmos gaat, het geheel en in samenhang. Minder belangrijk zijn voor hem politieke en sociale kwantiteit, belangrijker vindt hij de spirituele kwaliteit. Daar bedoelt hij mee dat we in ieder geval erkennen dat Iedereen anders, uniek en van waarde is. Daar bedoelt hij ook mee dat we weer uitstralen dat eigenlijk niemand het alleen kan doen. Iedereen is verbonden met andere mensen. Die andere mensen hebben we net zo goed als instituten nodig om te groeien en te bloeien. Laten we afstand nemen, zo straalt zijn boek uit, van ons egoïsme en onze zelfingenomenheid en onszelf bejubelen op de manier zoals Whitman dit voor ogen had, ook al staat dit heel ver af van wat we dagelijks om ons heen horen, zien en ervaren:

#quote(block: true)[
#emph[Dit is wat je moet doen: heb de aarde en de zon en de dieren lief, veracht de rijken, geef een aalmoes aan iedereen die erom vraagt, sta op voor de dommen en dwazen, wijd je inkomen en arbeid aan anderen, haat tirannen, twist niet over God, bejegen gewone mensen geduldig en coulant, neem voor niets en niemand je hoed af, ga vrijelijk om met krachtige, onopgeleide mannen en vrouwen en met jongens en meisjes en met de moeders van gezinnen, lees deze bladen in de open lucht elk seizoen elk jaar van je leven, onderzoek opnieuw wat je op school of in de kerk of in de boeken verteld is, verwerp alles wat je besmet, en je bloedeigen vlees zal een groot gedicht zijn, en niet alleen rijkelijk vloeien in je woorden, maar ook in de stille welving van je lippen en je gezicht en tussen de wimpers van je ogen in alle bewegingen en gewrichten van je lichaam] (p.~22)
]

\

#align(center)[
#box(image("Screenshot1.png", width: 40%,))
]
\
Harrie Jonkman | #link("www.harriejonkman.nl")[website] | email: harriejonkman\@xs4all.nl) | tel.: 0031634738591 | #link("https://github.com/Jonkman1")[github]

#bibliography("ref.bib")

