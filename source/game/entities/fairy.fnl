(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :fairy
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)]

  (fn plan-next-step [state {:state {: graph : graph-locations : grid-w} &as scene}]
    (let [goal
          (?. graph-locations :tree)
          ;; (case state.state
          ;;        :order (?. graph-locations :wait)
          ;;        :leave (?. graph-locations :exit)
          ;;        _ nil)
          ;; TODO: XY on nodes seems +1 each way. coords 1 based?
          curr (if goal (graph:nodeWithID (+ (* grid-w state.tile-y) (+ state.tile-x 1))))
          ;; curr (if goal (graph:nodeWithXY (+ (inspect state.tile-y) 1) (+ (inspect state.tile-x) 1)))
          path (if curr (graph:findPath curr goal))
          ;; _ (inspect {:x curr.x :y curr.y})
          ;; _ (inspect (curr:connectedNodes))
          ;; _ (inspect path)
          next-step (?. path 2)]
      (if
       (and (= (?. curr :x) (?. goal :x)) (= (?. curr :y) (?. goal :y))) :at-goal
       (= (type next-step) "nil") :pause
       (< (- next-step.y 1) state.tile-y) :up
       (> (- next-step.x 1) state.tile-x) :right
       (< (- next-step.x 1) state.tile-x) :left
       (> (- next-step.y 1) state.tile-y) :down
       :pause)))

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self} map-state]
    (let [(dx dy) (self:tile-movement-react! state.speed)]
      (if (and (= dx 0) (= dy 0))
          (case (plan-next-step state map-state)
            :up (self:->up!)
            :down (self:->down!)
            :left (self:->left!)
            :right (self:->right!)
            ))
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
      )
    self)


  (fn update [{:state {: animation : dx : dy : walking?} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)

          ]
      (if walking?
          (animation:transition! :walking)
          (animation:transition! :standing {:if :walking}))
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (if (> count 0) (self:->stop!))
      (self:setImage (animation:getImage))
      (self:markDirty))
    )


  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   (animation:draw x y))

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

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
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true
                           :tile-x (div x tile-w) :tile-y (div y tile-h)})
      (tile.add! player {: tile-h : tile-w})
      player)))

