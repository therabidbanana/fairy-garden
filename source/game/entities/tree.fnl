(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :tree
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn interacted! [{:state { : dir : total-fairies : rejected-fairies : accepted-fairies} &as self} fairy]
    (if (>= fairy.state.happiness 5)
        (do
          (print "New fairy joined!")
          (tset self :state :accepted-fairies (+ accepted-fairies 1)))
        (do
          (print "Fairy left")
          (tset self :state :rejected-fairies (+ rejected-fairies 1))))

    (inspect self.state)
    {:set-state :at-tree}
    )

  (fn react! [{:state { : dir : total-fairies : rejected-fairies : accepted-fairies} &as self} $scene]
    (if (>= (+ rejected-fairies accepted-fairies) total-fairies)
        ($ui:open-textbox! {:text (.. "All fairies accounted for. " accepted-fairies " of " total-fairies " are staying.")
                            :action #(scene-manager:select! :menu)} ))
    )
  (fn collisionResponse [self other]
    :overlap)

  (fn parse-wave [{: wave_counts : wave_delays}]
    (var found 0)
    (each [i v (ipairs wave_counts)]
      (set found (+ found v)))
    found)

  (fn stars [{:state { : dir : total-fairies : accepted-fairies} &as self}]
    (if (= total-fairies accepted-fairies)
        3
        (>= accepted-fairies (* total-fairies 0.75))
        2
        (>= accepted-fairies (* total-fairies 0.5))
        1
        0))

  (fn new! [x y {: tile-h : tile-w :layer-details { : grid-w : locations : wave-details}}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          tree (gfx.sprite.new)]
      ;; (tset node-list (+ (* tile-y grid-w) (+ tile-x 1)) 1)
      (tree:setBounds x y 64 32)
      (tree:setCollideRect 0 0 64 32)
      (tree:setGroups [4])
      (tree:setCollidesWithGroups [3])
      (tset tree :react! react!)
      (tset tree :collisionResponse collisionResponse)
      (tset tree :interacted! interacted!)
      (tset tree :stars stars)
      (tset tree :state {:accepted-fairies 0
                         :rejected-fairies 0
                         :total-fairies (parse-wave wave-details)})
      (tset tree :tree? true)
      (tset locations :tree {: tile-x : tile-y})
      tree)))
