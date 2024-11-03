(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :redirect
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   life-bar      (require :source.game.entities.life_bar)
   $ui           (require :source.lib.ui)]
  (local cost 1)

  (fn interacted! [{:state { : dir : water : image} &as self} fairy]
    (case dir
      :up (tset self :state :dir :down)
      :down (tset self :state :dir :up)
      :left (tset self :state :dir :right)
      :right (tset self :state :dir :left)
      _ nil)
    (self:setImage (image:getImage (case self.state.dir :left 1 :up 2 :right 3 :down 4)))
    (self:markDirty)
    (tset self :state :water (- water 1))
    {:set-state dir})

  (fn water! [{:state { : dir : water} &as self} val]
    (let [val (or val 1)]
      (tset self :state :water (clamp 0 (+ water val) 8))))

  (fn turn! [{:state {: dir : image} &as self} new-dir]
    (self:setImage (image:getImage (case new-dir :left 1 :up 2 :right 3 :down 4)))
    (tset self.state :dir new-dir))

  (fn player-interact! [{:state { : dir : water} &as self} primary?]
    (if primary?
        (self:turn! (case dir :left :up :up :right :right :down :down :left))
        (self:water! 1))
    )

  (fn react! [{:state { : dir : water} &as self}]
    (when (<= water 0)
      (print "Out of water")
      (self.life-bar:remove)
      (self:remove)))

  (fn collisionResponse [self other]
    :overlap)

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          dir (or (?. fields :dir) :right)
          image (gfx.imagetable.new :assets/images/splitter)
          redirect (gfx.sprite.new)
          ]
      (redirect:setImage (image:getImage (case dir :left 1 :up 2 :right 3 :down 4)))
      (redirect:setCenter 0 0)
      (redirect:setBounds x y 32 32)
      (redirect:setCollideRect 0 0 32 32)
      (redirect:setGroups [4])
      (redirect:setCollidesWithGroups [3])
      (tset redirect :life-bar (life-bar.new! x y {:linked redirect :curr 8 :field :water}))
      (tset redirect :react! react!)
      (tset redirect :water! water!)
      (tset redirect :turn! turn!)
      (tset redirect :player-interact! player-interact!)
      (tset redirect :interacted! interacted!)
      (tset redirect :collisionResponse collisionResponse)
      (tset redirect :state {: image : dir :water 8})
      redirect)))
