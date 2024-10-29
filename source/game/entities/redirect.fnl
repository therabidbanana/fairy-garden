(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :redirect
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)]

  (fn react! [{:state { : dir : water} &as self}]
    (when (<= water 0)
      (print "Out of water")
      (self:remove)))

  (fn interacted! [{:state { : dir : water} &as self} fairy]
    (tset self :state :water (- water 1))
    {:set-state dir}
    )

  (fn water! [{:state { : dir : water} &as self} val]
    (let [val (or val 1)
          new-water (clamp 0 (+ water val) 8)]
      (print (.. "Watered! " new-water))
      (tset self :state :water new-water)))

  (fn collisionResponse [self other]
    :overlap)

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          dir (or (?. fields :dir) :right)
          image (gfx.imagetable.new :assets/images/redirect)
          redirect (gfx.sprite.new)]
      (redirect:setImage (image:getImage (case dir :left 1 :up 2 :right 3 :down 4)))
      (redirect:setCenter 0 0)
      (redirect:setBounds x y 32 32)
      (redirect:setCollideRect 0 0 32 32)
      (redirect:setGroups [4])
      (redirect:setCollidesWithGroups [3])
      (tset redirect :react! react!)
      (tset redirect :water! water!)
      (tset redirect :interacted! interacted!)
      (tset redirect :collisionResponse collisionResponse)
      (tset redirect :state {: dir :water 8})
      redirect)))
