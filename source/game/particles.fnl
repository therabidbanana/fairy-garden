(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(pd/import :CoreLibs/animation)
(pd/import :CoreLibs/easing)
(pd/import :CoreLibs/animator)

(let [gfx playdate.graphics
      animation  gfx.animation
      sprite gfx.sprite]

  (local state {:particles []})

  (fn draw-all []
    (let [transitioned (icollect [i particle (ipairs state.particles)]
                         (let [{: anim : x : y} particle]
                           (particle.anim:draw x y)
                           (if (particle.anim:isValid) particle)))]
      (tset state :particles transitioned)))

  (fn splash! [x y]
    (let [image (gfx.imagetable.new :assets/images/splash)
          anim (gfx.animation.loop.new 80 image false)]
      (table.insert state.particles {: anim : x : y})))

  (fn heart! [x y]
    (let [image (gfx.imagetable.new :assets/images/heart)
          anim (gfx.animation.loop.new 110 image false)]
      (table.insert state.particles {: anim : x : y})))

  (fn sad! [x y]
    (let [image (gfx.imagetable.new :assets/images/sad)
          anim (gfx.animation.loop.new 110 image false)]
      (table.insert state.particles {: anim : x : y})))


  {: splash! : draw-all : heart! : sad!})
