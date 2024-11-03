(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :marigold
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)]

  (local cost 8)
  (fn interacted! [{:state { : dir } &as self} fairy]
    {:add-happiness 1}
    )

  (fn react! [{:state { : dir : tile-h : tile-w} &as self}])

  (fn collisionResponse [self other]
    :overlap)

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          dir (or (?. fields :dir) :right)
          image (gfx.imagetable.new :assets/images/marigold)
          redirect (gfx.sprite.new)]
      (redirect:setCenter 0 0)
      (redirect:setImage (image:getImage 1))
      (redirect:setBounds x y 32 32)
      (redirect:setCollideRect 0 0 32 32)
      (redirect:setGroups [4])
      (redirect:setCollidesWithGroups [3])
      (tset redirect :react! react!)
      (tset redirect :interacted! interacted!)
      (tset redirect :collisionResponse collisionResponse)
      (tset redirect :state {: dir : tile-h : tile-w})
      redirect)))
