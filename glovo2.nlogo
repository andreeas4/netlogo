patches-own [
  streets
  traffic
  assigned  ; variabilă pentru a marca dacă casa este asignată
]

turtles-own [
  work
  assigned-client  ; variabilă pentru a marca dacă turtle-ul este asignat unui client
]

globals[
  assigned-clients
  stores
  houses
]

breed [bikers biker]
breed [cars a-car]
breed [trucks a-truck]

to setup
  clear-all
  resize-world -16 16 -16 16
  create-bikers 10 [setxy random-xcor random-ycor]
  create-cars 10 [setxy random-xcor random-ycor]
  create-trucks 10 [setxy random-xcor random-ycor]
  set assigned-clients []
  reset-ticks
  set-turtles
  set-patches
  set-streets
end

to set-turtles
  ask turtles [
    if breed = bikers [
      set size 3
      set shape "deliver"
      set color yellow
      set work 0
    ]
    if breed = cars [
      set size 2
      set shape "car"
      set color blue
    ]
    if breed = trucks [
      set size 3
      set shape "truckg"
      set color yellow
      set work 0
    ]
  ]
end

to set-patches
  ask patches [ set pcolor grey ]
end

to set-streets
  let x -17
  let i 0

  while [x < 17] [
    let y -17

    while [y < 17] [
      ask patch x y [
        set pcolor black
      ]

      set i x
      ask patch i y [
        set pcolor black
        set streets 1
      ]

      ask patch y x [
        set pcolor black
        set streets 1
      ]

      set i x
      ask patch y i [
        set pcolor black
      ]

      set y y + 1
    ]
    set x x + 4
  ]
end

to set-the-stores
  check-store-placement
  tick
end

to set-the-client
  check-house-placement
  tick
end

to check-store-placement
  if mouse-down? [
    ask patch (round mouse-xcor) (round mouse-ycor) [
      ifelse pcolor = red
        [ unbecome-store ]
        [ set stores []
          become-store ]
    ]
  ]
end

to unbecome-store
  set pcolor grey
  set stores (remove self stores)
end

to become-store
  set pcolor red
  set stores (fput self stores)
end

to check-house-placement
  if mouse-down? [
    ask patch (round mouse-xcor) (round mouse-ycor) [
      ifelse pcolor = blue
        [ unbecome-house ]
        [ set houses []
          become-house ]
    ]
  ]
end

to unbecome-house
  set pcolor grey
  set houses (remove self houses)
  set assigned 0  ; casa nu mai este asignată
end

to become-house
  set stores []
  set pcolor blue
  set houses (fput self houses)
  set assigned 1  ; casa este asignată
end

to move-towards-streets
  ask turtles [
    let next-patch patch-ahead 1
    ifelse [streets] of next-patch = 1 [
      move-to next-patch
    ] [
      ; Nu face nimic dacă următorul patch nu are streets = 1
    ]
  ]
end

to move-to-streets
  let targets patches with [streets = 1]
  ask turtles [
    let target min-one-of targets [distance myself]
    if target != nobody [
      face target
      forward 1
    ]
  ]
end

to go-to-store
  ; Agenții trucks și bikers merg la magazin doar dacă au work setat la 0
  ask trucks with [work = 0] [
    let nearest-store min-one-of patches with [pcolor = red] [distance myself]
    if nearest-store != nobody [
      if patch-here != nearest-store [
        move-to nearest-store
        ; Verificăm dacă am ajuns la magazin
        if patch-here = nearest-store [
          set work 1
        ]
        ; Dacă nu am ajuns la magazin, căutăm cel mai apropiat patch negru
        let nearest-black-patch min-one-of neighbors4 with [pcolor = black] [distance nearest-store]
        if nearest-black-patch != nobody and patch-here != nearest-black-patch [
          ; Ne deplasăm către cel mai apropiat patch negru
          move-to nearest-black-patch
        ]
      ]
    ]
  ]
  ; Agenții bikers merg la magazin doar dacă au work setat la 0
  ask bikers with [work = 0] [
    let nearest-store min-one-of patches with [pcolor = red] [distance myself]
    if nearest-store != nobody [
      if patch-here != nearest-store [
        move-to nearest-store
        ; Verificăm dacă am ajuns la magazin
        if patch-here = nearest-store [
          set work 1
        ]
        ; Dacă nu am ajuns la magazin, căutăm cel mai apropiat patch negru
        let nearest-black-patch min-one-of neighbors4 with [pcolor = black] [distance nearest-store]
        if nearest-black-patch != nobody and patch-here != nearest-black-patch [
          ; Ne deplasăm către cel mai apropiat patch negru
          move-to nearest-black-patch
        ]
      ]
    ]
  ]
end

to go-to-client
  ; Agenții trucks cu work 1 livrează la clienți
  ask trucks with [work = 1] [
    pen-down  ; activăm pen-down
    let nearest-client min-one-of patches with [pcolor = blue] [distance myself]
    if nearest-client != nobody [
      while [patch-here != nearest-client] [
        let nearest-black-patch min-one-of patches with [pcolor = black] [distance myself]
        if nearest-black-patch != nobody [
          move-to nearest-black-patch
          wait 0.01  ; adaugăm o pauză scurtă pentru a încetini mișcarea
        ]
      ]
      ; Verificăm dacă am ajuns la client
      if patch-here = nearest-client [
        ; Resetăm work pentru a simula finalizarea livrării
        set work 0
        ; Marca casa ca neasignată
        ask patch-here [
          set assigned 0
          unbecome-house
        ]
        pen-up  ; dezactivăm pen-down
      ]
    ]
  ]
  ; Agenții bikers cu work 1 livrează la clienți
  ask bikers with [work = 1] [
    pen-down  ; activăm pen-down
    let nearest-client min-one-of patches with [pcolor = blue] [distance myself]
    if nearest-client != nobody [
      while [patch-here != nearest-client] [
        let nearest-black-patch min-one-of patches with [pcolor = black] [distance myself]
        if nearest-black-patch != nobody [
          move-to nearest-black-patch
          wait 0.01  ; adaugăm o pauză scurtă pentru a încetini mișcarea
        ]
      ]
      ; Verificăm dacă am ajuns la client
      if patch-here = nearest-client [
        ; Resetăm work pentru a simula finalizarea livrării
        set work 0
        ; Marca casa ca neasignată
        ask patch-here [
          set assigned 0
          unbecome-house
        ]
        pen-up  ; dezactivăm pen-down
      ]
    ]
  ]
end

to delivery
  ask bikers [
    if work = 0 [
      go-to-store
    ]
    if work = 1 [
      go-to-client
    ]
  ]
  ask trucks [
    if work = 0 [
      go-to-store
    ]
    if work = 1 [
      go-to-client
    ]
  ]
end

to drive
  ask turtles [
    if any? patches with [pcolor = black] [
      let target one-of patches with [pcolor = black]
      if target != patch-here [
        set heading towards target
        fd 1
        wait 0.01  ; adaugăm o pauză scurtă pentru a încetini mișcarea
      ]
    ]
  ]
end

to start
  move-to-streets
  drive
  delivery
  tick
end
