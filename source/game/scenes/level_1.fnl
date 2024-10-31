(import-macros {: pd/import : defns : inspect : clamp : div} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_1
  [;; ldtk (require :source.lib.ldtk.loader)
   $ui (require :source.lib.ui)
   {: build! : stage-draw! : stage-tick!} (require :source.game.scenes.level_builder)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$]
    (let [state (build! level_1)]
      (tset $ :state state)))

  (fn exit! [$]
    (tset $ :state {})
    (playdate.graphics.setDrawOffset 0 0)
    )

  (fn tick! [{: state &as $scene}]
    (stage-tick! $scene))

  (fn draw! [$scene] (stage-draw! $scene))

  (fn debug-draw! [$]
    ;; ($.state.graph:draw)
    )
  )

