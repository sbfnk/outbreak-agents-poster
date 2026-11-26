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

// The six-step modelling workflow, with who does each step.
#let step(name, tag) = stack(
  dir: ttb, spacing: 12pt,
  block(height: 3.6em, width: 100%)[#align(center + bottom)[#text(size: 24pt)[#tag]]],
  rect(width: 100%, height: 70pt, radius: 10pt, stroke: 4pt + teal, fill: wash)[
    #align(center + horizon)[#text(size: 27pt, weight: "bold", fill: teal)[#name]]
  ],
)
#let arrow = align(center + bottom)[#pad(bottom: 16pt)[#text(size: 40pt, fill: teal)[→]]]
#let workflow = grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  column-gutter: 6pt,
  step("Question", people[people]),
  arrow,
  step("Data", agents[agents read and digitise]),
  arrow,
  step("Model", [#people[people choose,] #agents[agents write]]),
  arrow,
  step("Fit", agents[agents, every push]),
  arrow,
  step("Check", [#agents[agents run,] #people[people judge]]),
  arrow,
  step("Report", [#agents[agents draft,] #people[people sign]]),
)

// The cumulative-forecast bug, in order. Dots coloured by who acted.
#let event(when, who, body) = grid(
  columns: (30pt, 1fr), column-gutter: 14pt,
  pad(top: 6pt, circle(radius: 13pt, fill: if who == "people" { brick } else { slate })),
  [#text(size: 26pt, weight: "bold", fill: teal)[#when] \ #text(size: 26pt)[#body]],
)

// The 26 June forecast of cumulative confirmed cases, recomputed from the
// release's posterior draws with the buggy and the fixed formula
// (scripts/cumulative_bug.py).
#let bugdata = json("data/cumulative_bug.json")
#let polyline(pts, stroke) = curve(stroke: stroke, curve.move(pts.at(0)), ..pts.slice(1).map(p => curve.line(p)))
#let band(lo, hi, fill) = curve(fill: fill, stroke: none, curve.move(lo.at(0)), ..lo.slice(1).map(p => curve.line(p)), ..hi.rev().map(p => curve.line(p)), curve.close())
#let forecast-plot(height: 300mm) = layout(size => {
  let w = size.width
  let h = height
  let (xmin, xmax) = (-25, 7)
  let (ymin, ymax) = (0, 2600)
  let (l, r, t, b) = (110pt, 30pt, 60pt, 70pt)
  let px(x) = l + (x - xmin) / (xmax - xmin) * (w - l - r)
  let py(y) = h - b - (y - ymin) / (ymax - ymin) * (h - t - b)
  let series(rows, i) = rows.map(d => (px(d.day), py(d.q.at(i))))
  let obs = bugdata.observed.map(d => (px(d.day), py(d.value)))
  box(width: w, height: h)[
    #for y in (0, 500, 1000, 1500, 2000, 2500) {
      place(top + left, line(start: (l, py(y)), end: (w - r, py(y)), stroke: 1pt + luma(225)))
      place(top + left, dx: 0pt, dy: py(y) - 14pt, box(width: l - 16pt, align(right, text(size: 22pt, fill: luma(110))[#y])))
    }
    #place(top + left, line(start: (l, h - b), end: (w - r, h - b), stroke: 2pt + ink))
    #for (x, lab) in ((-25, "29 May"), (-14, "9 June"), (0, "23 June"), (7, "30 June")) {
      place(top + left, dx: px(x) - 60pt, dy: h - b + 10pt, box(width: 120pt, align(center, text(size: 22pt, fill: luma(110))[#lab])))
    }
    #place(top + left, dx: 0pt, dy: -6pt, text(size: 24pt, weight: "bold")[Total confirmed cases to date])
    #place(top + left, line(start: (px(0), t + 30pt), end: (px(0), h - b), stroke: (paint: luma(150), thickness: 2pt, dash: "dashed")))
    #place(top + left, dx: px(0) - 120pt, dy: t + 30pt, text(size: 22pt, fill: luma(110))[cut-off])
    #place(top + left, line(start: (px(-21), py(bugdata.c0)), end: (w - r, py(bugdata.c0)), stroke: (paint: ink, thickness: 2pt, dash: "dotted")))
    #place(top + left, band(series(bugdata.bug, 0), series(bugdata.bug, 2), brick.transparentize(80%)))
    #place(top + left, band(series(bugdata.fix, 0), series(bugdata.fix, 2), teal.transparentize(70%)))
    #place(top + left, polyline(series(bugdata.bug, 1), (paint: brick, thickness: 5pt, dash: "dashed")))
    #place(top + left, polyline(series(bugdata.fix, 1), 5pt + teal))
    #place(top + left, polyline(obs, 5pt + ink))
    #for p in obs { place(top + left, dx: p.at(0) - 6pt, dy: p.at(1) - 6pt, circle(radius: 6pt, fill: ink)) }
    #place(top + left, dx: px(-24), dy: py(2550), grid(columns: (60pt, auto), column-gutter: 12pt, row-gutter: 14pt, align: horizon,
      line(length: 56pt, stroke: 5pt + ink), text(size: 24pt)[confirmed cases, reported],
      line(length: 56pt, stroke: 5pt + teal), text(size: 24pt, fill: teal, weight: "bold")[fixed: total + new cases (reconstructed)],
      line(length: 56pt, stroke: (paint: brick, thickness: 5pt, dash: "dashed")), text(size: 24pt, fill: brick, weight: "bold")[bug: total × growth factor (reconstructed)],
    ))


    #place(top + left, dx: px(0.6), dy: py(780), text(size: 24pt, fill: brick)[69 of 200 draws \ fell below this])
    #place(top + left, dx: px(-21), dy: py(bugdata.c0) - 34pt, text(size: 22pt, fill: ink)[1,118 already confirmed])
  ]
})


// The joint model, left to right: parameters, latent infections and onsets,
// then the observation process behind each of the nine fitted data streams.
// Drawn after the methods page of BVDOutbreakSize (diagrams/joint_overview.svg).
#let model-dag(height: 130mm) = layout(size => box(width: size.width, height: height, {
  let w = size.width
  let h = height
  let grey = luma(235)
  let blue = rgb("#dceaf3")
  let orange = rgb("#fbe3cc")
  let nbox(x, y, bw, bh, fill, body, size: 19pt) = place(top + left, dx: x, dy: y,
    box(width: bw, height: bh, fill: fill, stroke: 1.5pt + luma(150), radius: 6pt, inset: 6pt,
      align(center + horizon, text(size: size)[#body])))
  let seg(a, b) = place(top + left, line(start: a, end: b, stroke: 1.8pt + luma(120)))
  let streams = (
    ([Suspected cases], [report delay, reporting fraction], "on"),
    ([Treatment centres], [admissions, occupancy, beds], "on"),
    ([Specimens, confirmed cases], [receipt delay, test positivity], "on"),
    ([Recovered], [recovery delay], "on"),
    ([Confirmed deaths], [death-pool positivity], "on"),
    ([Suspected deaths], [onset-to-death delay, CFR], "on"),
    ([Onset curve], [reporting hazard], "on"),
    ([Uganda exports, deaths], [travel rate, export propensity], "inf"),
    ([Genetic TMRCA], [outbreak age], "inf"),
  )
  let n = streams.len()
  let rowh = h / n
  let (x1, w1) = (0pt, w * 0.17)
  let (x2, w2) = (w * 0.21, w * 0.19)
  let x3 = w * 0.45
  let (x4, w4) = (w * 0.73, w * 0.27)
  // parameters
  let ph = h * 0.2
  for (i, t) in ([Seeding], [Reproduction number by province], [Generation interval]).enumerate() {
    let y = h * 0.12 + i * (ph + h * 0.06)
    nbox(x1, y, w1, ph, grey, t)
    seg((x1 + w1, y + ph / 2), (x2, h * 0.3))
  }
  // latent
  let inf-y = h * 0.18
  let inf-h = h * 0.24
  nbox(x2, inf-y, w2, inf-h, blue, [*Infections* in 8 provinces, linked by importation])
  let on-y = h * 0.52
  let on-h = h * 0.16
  nbox(x2, on-y, w2, on-h, blue, [*Symptom onsets*])
  seg((x2 + w2 / 2, inf-y + inf-h), (x2 + w2 / 2, on-y))
  nbox(x2, h * 0.78, w2, h * 0.16, blue, [then 67 health zones], size: 17pt)
  seg((x2 + w2 / 2, on-y + on-h), (x2 + w2 / 2, h * 0.78))
  // observation processes and fitted streams
  for (i, (obs, proc, from)) in streams.enumerate() {
    let yc = i * rowh + rowh / 2
    let src = if from == "on" { (x2 + w2, on-y + on-h / 2) } else { (x2 + w2, inf-y + inf-h / 2) }
    seg(src, (x3 - 6pt, yc))
    place(top + left, dx: x3, dy: yc - 11pt, text(size: 17pt, fill: luma(80))[#proc])
    nbox(x4, i * rowh + 3pt, w4, rowh - 6pt, orange, obs, size: 18pt)
  }
}))

// ---------------------------------------------------------------- header
#let header = grid(
  columns: (1fr, auto), column-gutter: 30pt, align: (left + horizon, right + horizon),
  [
    #text(size: 76pt, weight: "bold", fill: teal)[Real-time outbreak analysis with AI agents]
    #v(-30pt)
    #text(size: 64pt, weight: "semibold", fill: slate)[Lessons from the 2026 Ebola outbreak]
    #v(6pt)
    #text(size: 34pt)[Sebastian Funk, Sam Abbott #todo[co-authors?] \ London School of Hygiene & Tropical Medicine]
  ],
  image("figures/lshtm-logo.png", height: 190pt),
)

// ---------------------------------------------------------------- main finding
#let finding = block(width: 100%, fill: teal, inset: (x: 40pt, y: 34pt), radius: 14pt)[
  #set text(fill: white)
  #grid(
    columns: (1fr, auto), column-gutter: 40pt, align: horizon,
    text(size: 50pt, weight: "bold")[#draft[AI agents let us analyse the outbreak at a speed and detail we couldn't manage before. The errors that mattered took expertise to spot. That makes expertise more valuable, not less.]],
    align(center)[
      #text(size: 120pt, weight: "bold")[99%] \
      #text(size: 26pt)[of added code and report lines \ committed by agent accounts] \
      #text(size: 18pt)[our Ebola model, to 5 October 2026]
    ],
  )
]

// ---------------------------------------------------------------- panels
#let panel1 = panel("1", draft[How we ran the analysis], [
    #workflow
    #v(18pt)
    #align(right)[#text(size: 24pt)[#people[■ people] #h(1em) #agents[■ agents] #h(1em) after Abbott et al. 2026]]
    #v(18pt)
    - #draft[Each change starts as an issue, from a #people[person] or an #agents[agent] instructed by one.]
    - #draft[An #agents[agent] drafts the pull request; since August, #agents[review agents] check many of them first.]
    - #draft[A #people[person] reviews and merges every change; the agent fixes, or argues its case.]
    - #draft[Everything is public. Working together is harder: the reasoning stays in one person's agent sessions.]
  ], [Human review is, at least in our set-up, still needed.])

#let panel2 = panel("2", draft[How big was the outbreak?], [
    #grid(columns: (1fr, 168mm), column-gutter: 24pt,
      [
        #text(size: 24pt)[#draft[As new situation reports came in, we estimated where cases were rising and how many people had been infected, including infections missed by surveillance. The first estimate was out a day after we started, with 188 updates since.]]
        #v(8pt)
        #grid(columns: (auto, auto), column-gutter: 30pt,
          [#text(size: 46pt, weight: "bold", fill: slate)[17k to 35k] \ #text(size: 20pt)[#draft[infections to date (90% interval)]]],
          [#text(size: 46pt, weight: "bold", fill: ink)[11,680] \ #text(size: 20pt)[#draft[confirmed, data to 18 November]]],
        )
      ],
      // The capture is 4500 × 3000: the top 15% is the control bar and the
      // right 28% the sidebar, both cropped off, leaving the map and its legend.
      {
        let w = 168mm
        let iw = w / 0.72
        let full = iw * 3000 / 4500
        box(clip: true, width: w, height: full * 0.85, stroke: 1pt + luma(200))[
          #place(top + left, dy: -full * 0.15, image("figures/bvd-map.png", width: iw, height: full, fit: "stretch"))
        ]
      },
    )
    #v(14pt)
    #model-dag(height: 100mm)
    #v(4pt)
    #text(size: 18pt, fill: luma(110))[#draft[The joint model: parameters (grey) and latent quantities (blue), fitted to nine data streams (orange). Data: DRC INSP situation reports.]]
  ], none)

#let panel3 = panel("3", draft[A forecast in which total cases could fall], [
    #grid(
      columns: (1.45fr, 1fr), column-gutter: 40pt,
      [
        #forecast-plot(height: 155mm)
        #text(size: 21pt, fill: luma(110))[One-week projection from the 26 June release (data to 23 June), recomputed from its 200 posterior draws of the growth rate with each formula; lines are medians, bands 90% intervals. The fixed line starts from the average daily new cases over the last six days and grows them at the same rate.]
      ],
      [
        #event("9 June", "agents")[#agents[Agent] writes the projection; tests pass and a #people[person] approves it]
        #v(16pt)
        #event("29 June, 07:19", "people")[#people[One of us], looking at a plot: "Why does our cumulative case count go down??"]
        #v(16pt)
        #event("08:20", "agents")[#agents[Agent] traces it to the code]
        #v(16pt)
        #event("3 July", "agents")[#agents[Agent]'s fix merged after #people[human] review]
        #v(24pt)
        #text(size: 30pt)[#draft[In the reconstruction, #text(weight: "bold", fill: brick)[35%] of the 200 posterior draws projected fewer cases a week ahead than had already been confirmed (red shading under the dotted line).]]
      ],
    )
    #v(20pt)
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 16pt,
      ..(
        ([Five forecast defects], draft[were in the published forecast until the August fix. Its 90% intervals covered nearly every observation: far too wide.], draft[Showed up in: scoring forecasts against what happened], brick),
        ([Wrong prior], draft[Test sensitivity taken from a study of a different ebolavirus. Raised from a bot account.], draft[Fixing it took knowing how the test fails in the field], brick),
        ([A model of its own], draft[Asked for a forecast for one health zone, an agent built a new model instead of using the published fits.], draft[Spotting it took: knowing what the request was for], brick),
        ([A data problem raised by a bot], draft[A silent revision of Beni cases in SitRep 160. Whether a person prompted it, the record does not show.], draft[Agents spot things too, but the record hides who did], slate),
      ).map(((t, b, k, c)) =>
        block(width: 100%, stroke: 3pt + c, radius: 8pt, inset: 14pt)[
          #text(size: 26pt, weight: "bold", fill: c)[#t] \
          #text(size: 23pt)[#b] \
          #text(size: 24pt, weight: "bold", fill: c)[#k]
        ])
    )
  ], draft[The tests passed and we approved the code. Spotting the error took a modeller who knew total cases can't fall.])

#let panel4 = panel("4", draft[Where should the expertise sit?], [
    #let place-col(name, example) = block(width: 100%)[
      #text(size: 30pt, weight: "bold", fill: teal)[#name] \
      #v(4pt)
      #text(size: 24pt)[#example]
    ]
    #grid(
      columns: (1fr,) * 5, column-gutter: 30pt,
      place-col([In people], draft[One of us spotted the falling forecast in a plot. Review when: at the start, every step or the end? Of the code or the outputs?]),
      place-col([In instructions], draft[A correction made twice goes into the agents' instructions, but agents don't reliably follow them.]),
      place-col([In tests], draft["Cumulative cases never fall" became a test only after the bug.]),
      place-col([In components], draft[Delay distributions come from a tested package of components.]),
      place-col([In packages], draft[An unregistered scoring package was dropped, so the agent wrote its own scoring.]),
    )
    #v(16pt)
    #grid(columns: (auto, 1fr, auto), column-gutter: 16pt, align: horizon,
      text(size: 22pt, fill: luma(110))[#draft[flexible, all checked by people]],
      line(length: 100%, stroke: 4pt + teal),
      text(size: 22pt, fill: luma(110))[#draft[checked once, hard to adapt]],
    )
    #v(12pt)
    #text(size: 26pt)[#draft[#text(weight: "bold", fill: slate)[Our hypothesis:] review and token costs both fall as more expertise is built into validated components.]]
  ], draft[How best to encode human expertise, and where it should sit, is completely unresolved. That is what we want to measure.])

// ---------------------------------------------------------------- footer
#let footer = grid(
  columns: (auto, auto, 1fr), column-gutter: 24pt, align: horizon,
  qrcode("https://epiforecasts.io/BVDOutbreakSize/stable/", width: 150pt),
  [
    #text(size: 30pt, weight: "bold", fill: teal)[Live report and dashboard] \
    #text(size: 24pt)[epiforecasts.io/BVDOutbreakSize]
  ],
  align(right)[#block(fill: brick, inset: (x: 30pt, y: 20pt), radius: 10pt, width: 95%)[
    #set text(fill: white)
    #align(left)[
      #text(size: 44pt, weight: "bold")[#draft[Where do the next experts come from, if agents do the making?]]
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
  grid.cell(colspan: 2, block(height: 357mm, panel3)),
  grid.cell(colspan: 2, block(height: 175mm, panel4)),
  grid.cell(colspan: 2, stack(dir: ttb, spacing: 14pt, line(length: 100%, stroke: 2pt + teal), footer)),
)
