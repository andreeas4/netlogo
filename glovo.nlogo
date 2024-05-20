;create-temporary-plot-pen string
;A new temporary plot pen with the given name is created in the current plot and set to be the current pen.
;Few models will want to use this primitive, because all temporary pens disappear when clear-plot or clear-all-plots are called. The normal way to make a pen is to make a permanent pen in the plot's Edit dialog.
;I want to se the path of my delivery-guys from stores to clients

patches-own [
  streets
  traffic
]

turtles-own [
  work]

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
    set work 0]
    if breed = cars [
      set size 2
      set shape "car"
      set color blue]
    if breed = trucks[
      set size 3
      set shape "truckg"
      set color yellow
    set work 0]
  ]
end
to set-patches
  ask patches[ set pcolor grey]
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

      ask patch y x  [
        set pcolor black
        set streets 1
      ]

      set i x
      ask patch y i  [
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
;punem strada casele si magazinele

;to start
  ;drive
  ;move-to-streets
  ;move-towards-streets


  ;tick

;end


to check-store-placement
  if mouse-down?
  [ask patch (round mouse-xcor) (round mouse-ycor)
    [ ifelse pcolor = red
      [unbecome-store]
      [ set stores []
        become-store]
  ]]
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
  if mouse-down?
  [ask patch (round mouse-xcor) (round mouse-ycor)
    [ ifelse pcolor = blue
      [unbecome-house]
      [ set houses []
        become-house]
  ]]
end
       to unbecome-house
       set pcolor grey
       set houses (remove self houses)
       end

      to become-house
       set stores []
       set pcolor blue
       set houses (fput self houses)
     end








to move-towards-streets
  ask turtles [
    let next-patch patch-ahead 1
    ifelse [streets] of next-patch = 1 [
      move-to next-patch
    ] [
      ; Do nothing if the next patch doesn't have streets = 1
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

to start
  move-to-streets
  drive
  delivery
 
  tick
end
to drive
  ask turtles [
    if any? patches with [pcolor = black] [
      set heading towards one-of patches with [pcolor = black]
      fd 1
    ]
  ]
end

to delivery
  ask bikers [
    go-to-store
    let current-patch patch-here
    if [pcolor] of current-patch = red [
      set work work + 1
    
    ]
  ]
  ask trucks [
    go-to-store
    let current-patch patch-here
    if [pcolor] of current-patch = red [
      set work work + 1
    
    ]
  ]
  
end


to go-to-store
  ; Fiecare agent găsește cel mai apropiat magazin și se deplasează către el
  let nearest-store min-one-of patches with [pcolor = red] [distance myself]
  if nearest-store != nobody [
    move-to nearest-store
    ; Căutăm cel mai apropiat patch negru
    let nearest-black-patch min-one-of neighbors4 with [pcolor = black] [distance nearest-store]
    if nearest-black-patch != nobody [
      ; Ne deplasăm către cel mai apropiat patch negru
      move-to nearest-black-patch
    ]
  ]
end

to go-to-store
  ; Agenții trucks merg la magazin doar dacă au work setat la 0
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
    let nearest-client min-one-of patches with [pcolor = blue] [distance myself]
    if nearest-client != nobody [
      if patch-here != nearest-client [
        move-to nearest-client
        ; Verificăm dacă am ajuns la client
        if patch-here = nearest-client [
          ; Resetăm work pentru a simula finalizarea livrării
          set work 0
        ]
        ; Dacă nu am ajuns la client, căutăm cel mai apropiat patch negru
        let nearest-black-patch min-one-of neighbors4 with [pcolor = black] [distance nearest-client]
        if nearest-black-patch != nobody and patch-here != nearest-black-patch [
          ; Ne deplasăm către cel mai apropiat patch negru
          move-to nearest-black-patch
        ]
      ]
    ]
  ]
  ; Agenții bikers cu work 1 livrează la clienți
  ask bikers with [work = 1] [
    let nearest-client min-one-of patches with [pcolor = blue] [distance myself]
    if nearest-client != nobody [
      if patch-here != nearest-client [
        move-to nearest-client
        ; Verificăm dacă am ajuns la client
        if patch-here = nearest-client [
          ; Resetăm work pentru a simula finalizarea livrării
          set work 0
        ]
        ; Dacă nu am ajuns la client, căutăm cel mai apropiat patch negru
        let nearest-black-patch min-one-of neighbors4 with [pcolor = black] [distance nearest-client]
        if nearest-black-patch != nobody and patch-here != nearest-black-patch [
          ; Ne deplasăm către cel mai apropiat patch negru
          move-to nearest-black-patch
        ]
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

to drive-delivery
  ask trucks [
    if any? patches with [pcolor = black] [
      let target one-of patches with [pcolor = black]
      if target != patch-here [
        set heading towards target
        fd 1
      ]
    ]
  ]
  ask bikers [
    if any? patches with [pcolor = black] [
      let target one-of patches with [pcolor = black]
      if target != patch-here [
        set heading towards target
        fd 1
      ]
    ]
  ]
end


