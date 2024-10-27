(import-macros {: pd/import : defns : inspect : clamp : div} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_0
  [entity-map (require :source.game.entities.core)
   ;; ldtk (require :source.lib.ldtk.loader)
   {: prepare-level!} (require :source.lib.level)
   $ui (require :source.lib.ui)
   pd playdate
   gfx pd.graphics]

  (fn -node-list! [size]
    (local t {})
    (for [i 1 size]
      (tset t i 1))
    t)

  (fn enter! [$]
    (let [
          ;; Option 1 - Loads at runtime
          ;; loaded (prepare-level! (ldtk.load-level {:level 0}) entity-map)
          ;; Option 2 - relies on deflevel compiling
          tile-size 32
          grid-w (div level_0.w tile-size)
          grid-h (div level_0.h tile-size)
          node-list (-node-list! (* grid-w grid-h))
          locations {}

          {: stage-width : stage-height
           &as loaded} (prepare-level! level_0 entity-map {:floor {:z-index -110}
                                                           :tree  { : locations : node-list : grid-w : grid-h}
                                                           :tiles {:z-index 10}})
          _ (each [_ v (ipairs (playdate.graphics.sprite.getAllSprites))]
              (if (?. v :wall?)
                  (let [tile-x (div v.x tile-size)
                        tile-y (div v.y tile-size)]
                    (tset node-list (+ (* tile-y grid-w) (+ tile-x 1)) 0))
                  )
              )

          graph (playdate.pathfinder.graph.new2DGrid grid-w grid-h false node-list)
          graph-locations (collect [k v (pairs locations)]
                            ;; (values k (graph:nodeWithXY (+ v.tile-x 1) (+ v.tile-y 1)))
                            (values k (graph:nodeWithID (+ (* grid-w v.tile-y) (+ v.tile-x 1))))
                            )
          player (?. (icollect [_ v (ipairs loaded.entities)]
                       (if (?. v :player?) v)) 1)
          ]
      (tset $ :state {: player : stage-width : stage-height : graph : graph-locations : grid-w})
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

