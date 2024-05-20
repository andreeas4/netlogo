
;nu merg pe strazi cand fac delivery ul
patches-own [
  streets
  traffic
  assigned  ; variable to mark if the house is assigned
]

turtles-own [
  work
  assigned-client  ; variable to mark if the turtle is assigned to a client
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
  create-bikers 10 [ setxy random-xcor random-ycor ]
  create-cars 10 [ setxy random-xcor random-ycor ]
  create-trucks 10 [ setxy random-xcor random-ycor ]
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
  set stores remove self stores
end

to become-store
  set pcolor red
  set stores fput self stores
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
  set houses remove self houses
  set assigned 0  ; the house is no longer assigned
end

to become-house
  set stores []
  set pcolor blue
  set houses fput self houses
  set assigned 1  ; the house is assigned
end

to move-towards-streets
  ask turtles [
    let next-patch patch-ahead 1
    ifelse [streets] of next-patch = 1 [
      move-to next-patch
    ] [
      ; Do nothing if the next patch does not have streets = 1
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
  ; Trucks and bikers go to store only if work is set to 0
  ask trucks with [work = 0] [
    let nearest-store min-one-of patches with [pcolor = red] [distance myself]
    if nearest-store != nobody [
      move-to nearest-store
      ; Check if arrived at the store
      if patch-here = nearest-store [
        set work 1
      ]
    ]
  ]
  ; Bikers go to store only if work is set to 0
  ask bikers with [work = 0] [
    let nearest-store min-one-of patches with [pcolor = red] [distance myself]
    if nearest-store != nobody [
      move-to nearest-store
      ; Check if arrived at the store
      if patch-here = nearest-store [
        set work 1
      ]
    ]
  ]
end

to go-to-client
  ; Trucks with work 1 deliver to clients
  ask trucks with [work = 1] [
    pen-down  ; enable pen-down
    let nearest-client min-one-of patches with [pcolor = blue] [distance myself]
    if nearest-client != nobody [
      move-to nearest-client
      ; Check if arrived at the client
      if patch-here = nearest-client [
        ; Reset work to simulate delivery completion
        set work 0
        ; Mark house as unassigned
        ask patch-here [
          set assigned 0
          unbecome-house
        ]
        pen-up  ; disable pen-down
        wait 0.1  ; add a short pause when arriving at the client
      ]
    ]
  ]
  ; Bikers with work 1 deliver to clients
  ask bikers with [work = 1] [
    pen-down  ; enable pen-down
    let nearest-client min-one-of patches with [pcolor = blue] [distance myself]
    if nearest-client != nobody [
      move-to nearest-client
      ; Check if arrived at the client
      if patch-here = nearest-client [
        ; Reset work to simulate delivery completion
        set work 0
        ; Mark house as unassigned
        ask patch-here [
          set assigned 0
          unbecome-house
        ]
        pen-up  ; disable pen-down
        wait 0.1  ; add a short pause when arriving at the client
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
