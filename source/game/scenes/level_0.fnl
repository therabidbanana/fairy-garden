(import-macros {: pd/import : defns : inspect : clamp} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_0
  [entity-map (require :source.game.entities.core)
   ;; ldtk (require :source.lib.ldtk.loader)
   {: prepare-level!} (require :source.lib.level)
   $ui (require :source.lib.ui)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$]
    (let [
          ;; Option 1 - Loads at runtime
          ;; loaded (prepare-level! (ldtk.load-level {:level 0}) entity-map)
          ;; Option 2 - relies on deflevel compiling
          {: stage-width : stage-height
           &as loaded} (prepare-level! level_0 entity-map {:floor {:z-index -110}
                                                           :tiles {:z-index 10}})
          player (?. (icollect [_ v (ipairs loaded.entities)]
                       (if (?. v :player?) v)) 1)
          ]
      (tset $ :state {: player : stage-width : stage-height})
      )
    )

  (fn exit! [$]
    (tset $ :state {})
    )

  (fn tick! [{: state &as $scene}]
    (if ($ui:active?) ($ui:tick!) ;; tick if open
        (let [player-x state.player.x
              player-y state.player.y
              center-x (clamp 0 (- player-x 200) (- state.stage-width 400))
              center-y (clamp 0 (- player-y 120) (- state.stage-height 240))]
          (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                            (if (?. ent :react!) (ent:react! $scene))))
          (gfx.setDrawOffset (- 0 center-x) (- 0 center-y))
          )
        ))

  (fn draw! [$]
    ;; ($.layer.tilemap:draw 0 0)
    ($ui:render!)
    )
  )

