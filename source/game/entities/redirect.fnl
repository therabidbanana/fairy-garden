(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :redirect
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)]
  (local cost 1)

  (fn react! [{:state { : dir : water : water-bar} &as self}]
    (when (<= water 0)
      (print "Out of water")
      (self:remove)
      (water-bar:remove)
      ))

  (fn interacted! [{:state { : dir : water} &as self} fairy]
    (self:update-water! (- water 1))
    {:set-state dir}
    )

  (fn turn! [{:state {: dir : image} &as self} new-dir]
    (self:setImage (image:getImage (case new-dir :left 1 :up 2 :right 3 :down 4)))
    (tset self.state :dir new-dir))

  (fn player-interact! [{:state { : dir : water} &as self} primary?]
    (if primary?
        (self:turn! (case dir :left :up :up :right :right :down :down :left))
        (self:water! 1))
    )

  (fn water! [{:state { : dir : water} &as self} val]
    (let [val (or val 1)
          new-water (clamp 0 (+ water val) 8)]
      (self:update-water! new-water)))

  (fn update-water! [{:state { : dir : water : water-bar : water-image} &as self} new-water]
    (print (.. "Watered! " new-water))
    (if (> new-water 0)
        (water-bar:setImage (water-image:getImage new-water)))
    (tset self :state :water new-water)
    )

  (fn collisionResponse [self other]
    :overlap)

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          dir (or (?. fields :dir) :right)
          image (gfx.imagetable.new :assets/images/redirect)
          redirect (gfx.sprite.new)
          water-image (gfx.imagetable.new :assets/images/life-bar)
          water-bar (gfx.sprite.new)
          water 8]
      (redirect:setImage (image:getImage (case dir :left 1 :up 2 :right 3 :down 4)))
      (redirect:setCenter 0 0)
      (water-bar:setImage (water-image:getImage water))
      (water-bar:setCenter 0 0)
      (water-bar:setBounds x y 32 8)
      (redirect:setBounds x y 32 32)
      (redirect:setCollideRect 0 0 32 32)
      (redirect:setGroups [4])
      (redirect:setCollidesWithGroups [3])
      (tset redirect :base-add redirect.add)
      (tset redirect :add #(do ($1:base-add) ($1.state.water-bar:add)))
      (tset redirect :react! react!)
      (tset redirect :water! water!)
      (tset redirect :interacted! interacted!)
      (tset redirect :turn! turn!)
      (tset redirect :update-water! update-water!)
      (tset redirect :player-interact! player-interact!)
      (tset redirect :collisionResponse collisionResponse)
      (tset redirect :state {: dir : water : image : water-bar : water-image})
      redirect)))
