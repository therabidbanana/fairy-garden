(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :redirect
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)]

  (fn interacted! [{:state { : dir : water} &as self} fairy]
    (case dir
      :up (tset self :state :dir :down)
      :down (tset self :state :dir :up)
      :left (tset self :state :dir :right)
      :right (tset self :state :dir :left)
      _ nil)
    (tset self :state :water (- water 1))
    {:set-state dir})

  (fn -get-facing-sprite [{:state { : dir : water : timer} &as self}]
    (let [x (case dir
              :left (- self.x 1)
              :right (+ self.x 1)
              _ self.x)
          y (case dir
              :up (- self.y 1)
              :down (+ self.y 1)
              _ self.y)
          (x y coll count) (self:checkCollisions x y)]
      (?. coll 1 :other)))

  (fn react! [{:state { : dir : water : timer : max-timer} &as self}]
    (let [new-t (- timer 1)
          to-water (self:-get-facing-sprite)]
      (if (<= new-t 0)
          (do
            (if (?. to-water :water!) (to-water:water!))
            (tset self :state :dir (case dir
                                     :up :right
                                     :right :down
                                     :down :left
                                     :left :up))
            (tset self :state :timer max-timer))
          (tset self :state :timer new-t)
          )))

  (fn collisionResponse [self other]
    :overlap)

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          dir (or (?. fields :dir) :right)
          redirect (gfx.sprite.new)]
      (redirect:setCenter 0 0)
      (redirect:setBounds x y 32 32)
      (redirect:setCollideRect 0 0 32 32)
      (redirect:setGroups [4])
      (redirect:setCollidesWithGroups [3 4])
      (tset redirect :react! react!)
      (tset redirect :-get-facing-sprite -get-facing-sprite)
      ;; Sprinklers - should they interact with fairies?
      ;; (tset redirect :interacted! interacted!)
      (tset redirect :collisionResponse collisionResponse)
      (tset redirect :state {:timer 100 :max-timer 100 : dir })
      redirect)))
