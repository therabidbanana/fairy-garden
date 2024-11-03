(import-macros {: pd/import : defns : inspect : clamp : div} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_1
  [;; ldtk (require :source.lib.ldtk.loader)
   $ui (require :source.lib.ui)
   {: build! : stage-draw! : stage-tick!} (require :source.game.scenes.level_builder)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$ game-state]
    (let [state (build! level_1)]
      (tset $ :state state)))

  (fn exit! [$ game-state]
    (tset game-state :level_1 {:stars (or ($.state.tree:stars) 0)})
    (tset $ :state {})
    (playdate.graphics.setDrawOffset 0 0)
    )

  (fn draw! [$scene] (stage-draw! $scene))

  (fn tick! [{: state &as $scene}]
    (stage-tick! $scene))

  (fn debug-draw! [$]
    ;; ($.state.graph:draw)
    ;; (gfx.sprite.performOnAllSprites
    ;;  (fn [ent]
    ;;    (if ent.collisionBox
    ;;        (gfx.drawRoundRect ent.collisionBox 1)
    ;;        ;; (gfx.drawCircleInRect ent.x ent.y ent.width ent.height 1)
    ;;        )))
    )
  )

