(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :redirect
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)
   $particles           (require :source.game.particles)
   ]
  (local cost 2)

  (fn interacted! [{:state { : dir : water} &as self} fairy]
    (case dir
      :up (tset self :state :dir :down)
      :down (tset self :state :dir :up)
      :left (tset self :state :dir :right)
      :right (tset self :state :dir :left)
      :left-up (tset self :state :dir :down)
      :right-down (tset self :state :dir :up)
      :left-down (tset self :state :dir :right)
      :right-up (tset self :state :dir :left)
      _ nil)
    {:add-happiness -1 :set-state dir})

  (fn -get-facing-x-y [{:state { : dir : water : timer} &as self}]
    (let [x (case dir
              :left (- self.x self.width)
              :left-up (- self.x self.width)
              :left-down (- self.x self.width)
              :right (+ self.x self.width)
              :right-up (+ self.x self.width)
              :right-down (+ self.x self.width)
              _ self.x)
          y (case dir
              :up (- self.y self.height)
              :left-up (- self.y self.height)
              :right-up (- self.y self.height)
              :down (+ self.y self.height)
              :left-down (+ self.y self.height)
              :right-down (+ self.y self.height)
              _ self.y)
          ]
      (values x y)))

  (fn -get-facing-sprite [{:state { : dir : water : timer} &as self}]
    (let [(x y) (-get-facing-x-y self)
          (x y coll count) (self:checkCollisions x y)]
      (?. coll 1 :other)))

  (fn react! [{:state { : image : dir : timer : max-timer} &as self}]
    (let [new-t (- timer 1)
          (splash-x splash-y) (self:-get-facing-x-y)
          to-water (self:-get-facing-sprite)]
      (if (<= new-t 0)
          (do
            (when (?. to-water :water!) (to-water:water!))
            ($particles.splash! splash-x splash-y)
            (tset self :state :dir (case dir
                                     :up :right-up
                                     :right-up :right
                                     :right :right-down
                                     :right-down :down
                                     :down :left-down
                                     :left-down :left
                                     :left :left-up
                                     :left-up :up
                                     ))
            (self:setImage (image:getImage (case self.state.dir :left 1 :up 2 :right 3 :down 4 :left-up 1 :right-up 2 :right-down 3 :left-down 4)))
            (self:markDirty)
            (tset self :state :timer max-timer))
          (tset self :state :timer new-t)
          )))

  (fn collisionResponse [self other]
    :overlap)

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          dir (or (?. fields :dir) :right)
          image (gfx.imagetable.new :assets/images/sprinkler)
          redirect (gfx.sprite.new)]
      (redirect:setImage (image:getImage (case dir :left 1 :up 2 :right 3 :down 4)))
      (redirect:setCenter 0 0)
      (redirect:setBounds x y 32 32)
      (redirect:setCollideRect 0 0 32 32)
      (redirect:setGroups [4])
      (redirect:setCollidesWithGroups [3 4])
      (tset redirect :react! react!)
      (tset redirect :-get-facing-sprite -get-facing-sprite)
      (tset redirect :-get-facing-x-y -get-facing-x-y)
      ;; Sprinklers - should they interact with fairies?
      (tset redirect :interacted! interacted!)
      (tset redirect :collisionResponse collisionResponse)
      (tset redirect :state {:timer 15 :max-timer 15 : dir : image})
      redirect)))
