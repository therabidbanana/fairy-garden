(import-macros {: pd/import : defns : inspect} :source.lib.macros)

(defns :LogoScreen
  [$ui (require :source.lib.ui)
   scene-manager (require :source.lib.scene-manager)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$]
    (let [logo (gfx.image.new :assets/images/team-haslem)
          ]
      (tset $ :anim (playdate.graphics.animator.new 3500 0 1 playdate.easingFunctions.outCubic))
      (tset $ :logo logo)
      (set $.anim.reverses true)
      )
    )

  (fn exit! [$]
    (tset $ :anim nil))

  (fn tick! [$]
    (if (or (playdate.buttonJustPressed playdate.kButtonA)
            (and $.anim ($.anim:ended)))
        (scene-manager:select! :title)
        )
    )
  (fn draw! [$]
    (gfx.clear)
    ($.logo:drawFaded 0 0 ($.anim:currentValue) gfx.image.kDitherTypeFloydSteinberg)
    ;; ($.layer.tilemap:draw 0 0)
    )
  )
