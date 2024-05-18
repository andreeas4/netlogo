;create-temporary-plot-pen string
;A new temporary plot pen with the given name is created in the current plot and set to be the current pen.
;Few models will want to use this primitive, because all temporary pens disappear when clear-plot or clear-all-plots are called. The normal way to make a pen is to make a permanent pen in the plot's Edit dialog.
;I want to se the path of my delivery-guys from stores to clients

patches-own [
  streets
  traffic
]

turtles-own [
  horizontal
  vertical
  speed]

globals[
  store
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

  reset-ticks
  set-turtles
  set-patches
  set-streets

end
to create-bikers-on-streets [num-agents]
  repeat num-agents [
    ; Get a random patch with streets = 1
    let candidate-patches patches with [streets = 1]
    let random-patch one-of candidate-patches
    if random-patch != nobody [
    ; Create a turtle on the selected patch
    create-bikers 1 [
      move-to random-patch
    ]]
  ]
end





to set-turtles
  ask turtles [
    if breed = bikers [
    set size 3
    set shape "deliver"
      set color yellow
    set speed 1]
    if breed = cars [
      set size 2
      set shape "car"
      set color blue]
    if breed = trucks[
      set size 3
      set shape "truckg"
      set color yellow
    set speed 3]
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








to set-traffic
  ask turtles [
    let current-patch patch-here
    ifelse [streets] of current-patch = 1 [
      ; Increment traffic count for patches with streets = 1 and turtles
      ask current-patch [
        set traffic traffic + 1
      ]
    ] [
      ; Reset traffic count for patches without streets = 1 or no turtles
      ask current-patch [
        set traffic 0
      ]
    ]
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

to go-to-store
  let nearest-store min-one-of patches with [stores] [distance myself]
  if nearest-store != nobody [
    move-to nearest-store
  ]
end

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
  ma-sa
end
to ma-sa
  ask turtles [
    if any? patches with [pcolor = black] [
      set heading towards one-of patches with [pcolor = black]
      fd 1
    ]
  ]
end


