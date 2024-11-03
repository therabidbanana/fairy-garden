(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :warp
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)]

  (fn new! [x y {: tile-h : tile-w : fields :layer-details {: levels : game-state }}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          unlock-stars  (if fields.unlock
                            (or (?. game-state fields.unlock :stars) 0)
                            3)
          image (gfx.imagetable.new :assets/images/lock)
          warp (gfx.sprite.new)]
      (warp:setCenter 0 0)
      (if (<= unlock-stars 1) (warp:setImage (image:getImage 1)))
      (warp:setBounds x y 32 32)
      (warp:setCollideRect 0 0 32 32)
      (warp:setGroups [4])
      (warp:setCollidesWithGroups [3])
      (tset warp :react! react!)
      (tset levels fields.level warp)
      (tset warp :collisionResponse :overlap)
      (tset warp :state {:level fields.level :title fields.title :unlock fields.unlock})
      warp)))
