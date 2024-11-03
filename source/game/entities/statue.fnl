(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :statue
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)]

  (fn interacted! [{:state { : dir } &as self} fairy]
    {:add-happiness 1}
    )

  (fn collisionResponse [self other]
    :overlap)

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          dir (or (?. fields :dir) :left)
          image (gfx.imagetable.new :assets/images/statue)
          redirect (gfx.sprite.new)]
      (redirect:setCenter 0 0)
      (redirect:setImage (image:getImage (case dir :left 1 _ 2)))
      (redirect:setBounds x y 32 32)
      (redirect:setCollideRect 0 0 32 32)
      (redirect:setGroups [4])
      (redirect:setCollidesWithGroups [3])
      (tset redirect :interacted! interacted!)
      (tset redirect :collisionResponse collisionResponse)
      (tset redirect :state {: dir : tile-h : tile-w})
      redirect)))
