// A0 portrait poster: real-time outbreak analysis with AI agents.
// Build: typst compile poster.typ (print copy: typst compile --input drafts=false poster.typ)
// Placeholders in brick italics mark text still to be written.

#import "@preview/tiaoma:0.3.0": qrcode

#let teal = rgb("#1f6f8b")
#let slate = rgb("#4a5899")
#let brick = rgb("#b5432f")
#let ink = rgb("#222222")
#let paper = rgb("#ffffff")
#let wash = rgb("#e3eef2")

#set page(width: 841mm, height: 1189mm, margin: (x: 32mm, y: 30mm), fill: paper)
#set text(font: "Open Sans", size: 30pt, fill: ink, lang: "en", region: "gb")
#set par(leading: 0.55em, spacing: 0.9em)
#set list(indent: 0.4em, body-indent: 0.5em, spacing: 0.7em)

#let todo(body) = text(fill: brick, style: "italic")[[#body]]
// Drafted text, marked until rewritten; build with --input drafts=false for print.
#let show-drafts = sys.inputs.at("drafts", default: "true") != "false"
#let draft(body) = if show-drafts { underline(stroke: 5pt + rgb("#f2c200"), offset: 6pt, evade: false, body) } else { body }

#let people(body) = text(fill: brick, weight: "bold")[#body]
#let agents(body) = text(fill: slate, weight: "bold")[#body]

// A panel: heading that states the point, body, and a conclusion box.
#let panel(number, heading, body, conclusion) = block(
  width: 100%, height: 100%, inset: 0pt,
)[
  #grid(
    columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
    box(fill: teal, inset: (x: 16pt, y: 6pt), radius: 6pt)[
      #text(fill: white, weight: "bold", size: 40pt)[#number]
    ],
    text(size: 44pt, weight: "bold", fill: teal)[#heading],
  )
  #v(10pt)
  #line(length: 100%, stroke: 3pt + teal)
  #v(14pt)
  #body
  #if conclusion != none [
    #place(bottom)[
      #block(width: 100%, fill: wash, inset: 22pt, radius: 10pt)[
        #text(size: 36pt, weight: "semibold", fill: teal)[#conclusion]
      ]
    ]
  ]
]

// The cumulative-forecast bug, in order. Dots coloured by who acted: humans
// brick, agents slate, grey where the record does not say.
#let event(when, who, body) = grid(
  columns: (30pt, 1fr), column-gutter: 14pt,
  pad(top: 4pt, circle(radius: 12pt, fill: if who == "humans" { brick } else if who == "agents" { slate } else { luma(170) })),
  [#text(size: 23pt, weight: "bold", fill: teal)[#when] \ #text(size: 23pt)[#body]],
)

// The 26 June release's published one-week forecast of cumulative confirmed
// cases, from its forecast table (results-1002), against the reported counts
// to the 23 June cut-off (data/cumulative_bug.json).
#let bugdata = json("data/cumulative_bug.json")
#let polyline(pts, stroke) = curve(stroke: stroke, curve.move(pts.at(0)), ..pts.slice(1).map(p => curve.line(p)))
// Central intervals for cumulative confirmed cases by 30 June (T+7).
#let published = (
  (level: "90%", lo: 322, hi: 3706, half: 16pt, fill: brick.transparentize(78%)),
  (level: "60%", lo: 650, hi: 1951, half: 26pt, fill: brick.transparentize(55%)),
  (level: "30%", lo: 874, hi: 1457, half: 36pt, fill: brick.transparentize(20%)),
)
#let forecast-plot(height: 300mm) = layout(size => {
  let w = size.width
  let h = height
  let (xmin, xmax) = (-14, 11)
  let (ymin, ymax) = (0, 4000)
  let (l, r, t, b) = (110pt, 20pt, 50pt, 70pt)
  let px(x) = l + (x - xmin) / (xmax - xmin) * (w - l - r)
  let py(y) = h - b - (y - ymin) / (ymax - ymin) * (h - t - b)
  let c0 = bugdata.c0
  let shown = bugdata.observed.filter(d => d.day >= xmin)
  let obs = shown.map(d => (px(d.day), py(d.value)))
  // Split the reported series at missing days so the line does not bridge them.
  let runs = shown.fold((), (acc, d) => {
    if acc.len() > 0 and d.day == acc.last().last().day + 1 { acc.last().push(d); acc } else { acc + ((d,),) }
  }).map(run => run.map(d => (px(d.day), py(d.value))))
  let xf = px(7)
  box(width: w, height: h)[
    #for y in (0, 1000, 2000, 3000, 4000) {
      place(top + left, line(start: (l, py(y)), end: (w - r, py(y)), stroke: 1pt + luma(225)))
      place(top + left, dx: 0pt, dy: py(y) - 14pt, box(width: l - 16pt, align(right, text(size: 22pt, fill: luma(110))[#y])))
    }
    #place(top + left, line(start: (l, h - b), end: (w - r, h - b), stroke: 2pt + ink))
    #for (x, lab) in ((-14, "9 June"), (-7, "16 June"), (0, "23 June"), (7, "30 June")) {
      place(top + left, dx: px(x) - 60pt, dy: h - b + 10pt, box(width: 120pt, align(center, text(size: 22pt, fill: luma(110))[#lab])))
    }
    #place(top + left, dx: 0pt, dy: -6pt, text(size: 24pt, weight: "bold")[Total confirmed cases to date])
    // Everything below the count already confirmed is impossible.
    #place(top + left, dx: px(0), dy: py(c0), rect(width: px(xmax) - px(0), height: py(0) - py(c0), fill: luma(238), stroke: none))
    #place(top + left, line(start: (px(xmin), py(c0)), end: (px(xmax), py(c0)), stroke: (paint: ink, thickness: 3pt, dash: "dashed")))
    #place(top + left, line(start: (px(0), t), end: (px(0), h - b), stroke: (paint: luma(150), thickness: 2pt, dash: "dotted")))
    #place(top + left, dx: px(0) + 10pt, dy: t, text(size: 22pt, fill: luma(110))[cut-off])
    #for run in runs.filter(r => r.len() > 1) { place(top + left, polyline(run, 5pt + ink)) }
    #for p in obs { place(top + left, dx: p.at(0) - 6pt, dy: p.at(1) - 6pt, circle(radius: 6pt, fill: ink)) }
    #for iv in published {
      place(top + left, dx: xf - iv.half, dy: py(iv.hi), rect(width: 2 * iv.half, height: py(iv.lo) - py(iv.hi), fill: iv.fill, stroke: none))
    }
    #for iv in published {
      let dx = if iv.level == "30%" { xf - 46pt - 50pt } else { xf + 46pt }
      place(top + left, dx: dx, dy: py(iv.lo) - 14pt, text(size: 22pt, fill: brick, weight: "bold")[#iv.lo])
    }
    #place(top + left, dx: xf + 46pt, dy: py(3706) - 14pt, text(size: 22pt, fill: brick, weight: "bold")[3,706])
    #place(top + left, dx: px(xmin) + 10pt, dy: py(c0) - 36pt, text(size: 24pt, weight: "bold")[1,118 already confirmed])
    #place(top + left, dx: px(0.4), dy: py(2700), box(width: xf - px(0.4) - 50pt, text(size: 24pt, fill: brick, weight: "bold")[over a third of the forecast lies in the grey]))
    #place(top + left, dx: px(xmin) + 10pt, dy: py(3900), grid(columns: (auto, auto), column-gutter: 12pt, row-gutter: 10pt, align: horizon,
      line(length: 56pt, stroke: 5pt + ink), text(size: 24pt)[confirmed cases, reported],
      stack(dir: ltr, rect(width: 18pt, height: 30pt, fill: brick.transparentize(78%)), rect(width: 18pt, height: 30pt, fill: brick.transparentize(55%)), rect(width: 18pt, height: 30pt, fill: brick.transparentize(20%))),
      text(size: 24pt, fill: brick, weight: "bold")[published 26 June: 90%, 60% and 30% intervals],
    ))
  ]
})

// ---------------------------------------------------------------- header
#let header = grid(
  columns: (1fr, auto), column-gutter: 30pt, align: (left + horizon, right + horizon),
  [
    #text(size: 76pt, weight: "bold", fill: teal)[Real-time outbreak analysis with AI agents]
    #v(-30pt)
    #text(size: 64pt, weight: "semibold", fill: slate)[Lessons from the 2026 Ebola outbreak in the DRC]
    #v(6pt)
    #text(size: 34pt)[Sebastian Funk, Sam Abbott \ London School of Hygiene & Tropical Medicine]
  ],
  image("figures/lshtm-logo.png", height: 190pt),
)

// ---------------------------------------------------------------- main finding
// Two halves: what agents made possible, and what it cost.
#let night = rgb("#2b3a4a")
#let finding-half(fill, title, body) = block(width: 100%, height: 74mm, fill: fill, inset: (x: 36pt, y: 26pt), radius: 14pt)[
  #set text(fill: white)
  #text(size: 46pt, weight: "bold")[#title]
  #v(2pt)
  #text(size: 30pt)[#body]
]
#let finding = grid(
  columns: (1fr, 1fr), column-gutter: 36pt, rows: auto,
  finding-half(teal, draft[Agents let us move fast], draft[Started 19 May, first estimate the next day; 192 published result releases and 24 model versions by 18 November.]),
  finding-half(night, draft[… but made errors we found hard to spot], draft[A published forecast let total cases fall below those already confirmed, after tests and human review.]),
)

// ---------------------------------------------------------------- panels
#let stat(value, label, fill: ink) = block[
  #text(size: 56pt, weight: "bold", fill: fill)[#value] \
  #text(size: 22pt)[#label]
]

#let panel1 = panel("1", draft[How big was the outbreak?], [
    #text(size: 24pt, fill: luma(90))[#draft[Democratic Republic of the Congo, data to 18 November 2026 (model release results-3541)]]
    #v(-2pt)
    #set text(size: 20pt)
    #grid(columns: (auto, auto, auto, auto), column-gutter: 1fr,
      stat(fill: slate, [17k to 35k #text(size: 22pt, weight: "regular")[90% interval]], draft[estimated cumulative infections]),
      stat([11,680], draft[reported confirmed cases]),
      stat(fill: teal, [9], draft[data streams]),
      stat(fill: teal, [67], draft[health zones]),
    )
    #v(8pt)
    // The capture is 4500 × 3000; the top 15% is the dashboard's control bar.
    #layout(size => {
      let w = size.width
      let full = w * 3000 / 4500
      box(clip: true, width: w, height: full * 0.85, stroke: 1pt + luma(200))[
        #place(top + left, dy: -full * 0.15, image("figures/bvd-map.png", width: w, height: full, fit: "stretch"))
      ]
    })
    #v(0pt)
    #text(size: 18pt, fill: luma(110))[#draft[Live dashboard: reproduction number by health zone. Data: DRC INSP situation reports.]]
  ], none)

#let panel2 = panel("2", draft[How we did it], [
    #image("figures/agents-swarm.png", width: 100%)
    #v(-6pt)
    #align(right)[#text(size: 18pt, fill: luma(110))[#draft[Each human directs their own agent account, which hands work to a swarm of agents.]]]
    #v(10pt)
    #grid(columns: (auto, auto, auto), column-gutter: 30pt,
      stat(fill: slate, [99%], draft[of added lines came from agent accounts]),
      stat(fill: brick, [582/586], draft[pull requests merged from a human's account]),
      stat(fill: brick, [34%], draft[of agent pull requests merged with no GitHub review by a human]),
    )
    #text(size: 18pt, fill: luma(110))[#draft[All to 5 October 2026.]]
    #v(14pt)
    #text(size: 30pt)[#draft[Two of us ran one model fitted to nine data streams, refitted with every situation report. We could not have built and kept it up by hand. The code, reports and pull requests are public. Much of the reasoning stayed in private agent sessions.]]
  ], draft[Agents wrote the code; humans decide what goes in.])

#let panel3 = panel("3", draft[How an error got past tests and review], [
    #grid(
      columns: (1.45fr, 1fr), column-gutter: 40pt,
      [
        #forecast-plot(height: 150mm)
        #text(size: 21pt, fill: luma(110))[#draft[Reported confirmed cases to the 23 June cut-off, and the one-week forecast for 30 June published on 26 June (release results-1002). Grey: totals below those already confirmed.]]
        #v(12pt)
        #text(size: 27pt)[#draft[One of our published outputs was a one-week forecast of cumulative cases. Its 90% interval went as low as 322 cases, when 1,118 had already been confirmed. The tests were written with the code and only drew a growing outbreak, so they never checked whether the total could fall.]]
      ],
      [
        #event("9 June", "agents")[#draft[#agents[Agent] rewrites the model in one 23,000-line pull request; its tests pass and a #people[human] approves it]]
        #v(10pt)
        #event("29 June, 07:19 BST", "humans")[#draft[#people[Human], looking at a plot: "Why does our cumulative case count go down??"]]
        #v(10pt)
        #event("08:20 to 09:00", "agents")[#draft[#agents[Agent] traces it to the code and posts a public issue. A #people[human] confirms the bug.]]
        #v(10pt)
        #event("3 July", "agents")[#draft[#agents[Agent]'s fix merged after #people[human] review]]
        #v(10pt)
        #event("26 to 27 August", "humans")[#draft[#people[Human] questions odd forecast plots; the #agents[agent]'s fixes correct a flaw in the July fix and four other defects]]
      ],
    )
    #v(16pt)
    #text(size: 28pt, weight: "bold", fill: teal)[#draft[Other errors]]
    #v(4pt)
    #grid(
      columns: (1fr, 1fr, 1fr), column-gutter: 16pt,
      ..(
        ([Intervals far too wide], draft[90% intervals covered nearly every observation until the 27 August fix.], draft[Scoring made it noticeable], teal),
        ([Wrong prior], draft[Test sensitivity from a study of a different ebolavirus.], draft[Caught by a human], brick),
        ([A silent data revision], draft[A situation report quietly changed past cases.], draft[Raised by an agent], slate),
      ).map(((t, b, k, c)) =>
        block(width: 100%, height: 57mm, stroke: 2pt + luma(180), radius: 8pt, inset: 14pt)[
          #text(size: 28pt, weight: "bold")[#t] \
          #text(size: 26pt)[#b] \
          #text(size: 26pt, weight: "bold", fill: c)[#k]
        ])
    )
  ], draft[Tests written alongside the code share its blind spots.])

#let panel4 = panel("4", draft[What should experts be doing?], [
    #let action(name, example) = block(width: 100%)[
      #text(size: 32pt, weight: "bold", fill: teal)[#name] \
      #v(4pt)
      #text(size: 27pt)[#example]
    ]
    #grid(
      columns: (1fr,) * 5, column-gutter: 30pt,
      action(draft[Reading the outputs], draft[A human saw the falling forecast in a plot, not in the code.]),
      action(draft[Writing the checks], draft["Totals never fall below those confirmed" would have caught it at once.]),
      action(draft[Designing the evaluation], draft[Checks only catch failures we foresee; scoring let us notice the wide intervals.]),
      action(draft[Setting the rules], draft[Require small changes: no one can review a 23,000-line change. Then check they are followed.]),
      action(draft[Building components], draft[Delay distributions, including the censoring, come from a tested package the agents reuse.]),
    )
    #v(16pt)
    #text(size: 30pt)[#draft[#text(weight: "bold", fill: slate)[Our hypothesis:] the more expertise goes into tested components and checks, the less review each change needs.]]
  ], draft[We will test whether validated components cut both review effort and errors.])

// ---------------------------------------------------------------- footer
#let footer = grid(
  columns: (auto, auto, 1fr), column-gutter: 24pt, align: horizon,
  qrcode("https://epiforecasts.io/BVDOutbreakSize/stable/", width: 120pt),
  [
    #text(size: 30pt, weight: "bold", fill: teal)[Live report and dashboard] \
    #text(size: 24pt)[epiforecasts.io/BVDOutbreakSize]
  ],
  align(right)[#block(fill: brick, inset: (x: 30pt, y: 20pt), radius: 10pt, width: 95%)[
    #set text(fill: white)
    #align(left)[
      #text(size: 35pt, weight: "bold")[#draft[If agents write the models, how will the next modellers learn to spot these errors?]]
    ]
  ]],
)

// ---------------------------------------------------------------- page
#grid(
  columns: (1fr, 1fr), rows: (auto, auto, 1fr, auto, auto, auto),
  column-gutter: 36pt, row-gutter: (30pt, 36pt, 36pt, 36pt, 30pt),
  grid.cell(colspan: 2, header),
  grid.cell(colspan: 2, finding),
  panel1, panel2,
  grid.cell(colspan: 2, block(height: 385mm, panel3)),
  grid.cell(colspan: 2, block(height: 145mm, panel4)),
  grid.cell(colspan: 2, stack(dir: ttb, spacing: 20pt, line(length: 100%, stroke: 2pt + teal), footer)),
)
