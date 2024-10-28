(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :fairy
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)]

  (fn plan-next-step [state {:state {: graph } &as scene}]
    (case state.state
      :left :left
      :right :right
      :up :up
      :down :down
      :tree
      (let [goal (graph:location-node :tree)
            curr (if goal (graph:at-tile state.tile-x state.tile-y))
            next-step (if curr (graph:next-step curr goal))]
        (if
         (and (= (?. curr :x) (?. goal :x)) (= (?. curr :y) (?. goal :y))) :at-goal
         (= (type next-step) "nil") :pause
         (< next-step.y state.tile-y) :up
         (> next-step.x state.tile-x) :right
         (< next-step.x state.tile-x) :left
         (> next-step.y state.tile-y) :down
         :pause))))

  (fn at-tree! [self]
    (print "Made it to tree!")
    (self:remove))

  (fn transition! [self state]
    (tset self :state :state state))

  (fn react-at-tile! [self]
    (let [curr-overlap (?. (self:overlappingSprites) 1)]
      (if (?. curr-overlap :state :dir)
          (self:transition! curr-overlap.state.dir)))
    )

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self} map-state]
    (let [(dx dy) (self:tile-movement-react! state.speed)
          stopped? (and (= dx 0) (= dy 0))]
      (if stopped?
          (do
            (self:react-at-tile!)
            (case (plan-next-step state map-state)
              :up (self:->up!)
              :down (self:->down!)
              :left (self:->left!)
              :right (self:->right!)
              :at-goal (self:at-tree!)
              )))
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
      )
    self)


  (fn update [{:state {: animation : dx : dy : walking?} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)
          walls (icollect [i v (ipairs collisions)] (if (?. v :other :wall?) v))
          wall-count (length walls)
          ]
      (if walking?
          (animation:transition! :walking)
          (animation:transition! :standing {:if :walking}))
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (when (> wall-count 0)
        (self:->stop!)
        ;; If redirected, set back on track
        (tset self :state :state :tree)
        )
      (self:setImage (animation:getImage))
      (self:markDirty))
    )


  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   (animation:draw x y))

  (fn collisionResponse [self other]
    (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w}]
    (let [image (gfx.imagetable.new :assets/images/fairy-sprite)
          animation (anim.new {: image :states [{:state :standing :start 1 :end 2 :delay 2300}
                                                {:state :walking :start 1 :end 2}
                                                ]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 24 24)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 0 0 32 32)
      (player:setGroups [3])
      (player:setCollidesWithGroups [4])
      ;; (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :collisionResponse collisionResponse)
      (tset player :at-tree! at-tree!)
      (tset player :transition! transition!)
      (tset player :react-at-tile! react-at-tile!)

      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true
                           :tile-x (div x tile-w) :tile-y (div y tile-h)
                           :state :tree})
      (tile.add! player {: tile-h : tile-w})
      player)))

