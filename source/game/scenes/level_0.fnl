(import-macros {: pd/import : defns : inspect : clamp : div} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_0
  [entity-map (require :source.game.entities.core)
   ;; ldtk (require :source.lib.ldtk.loader)
   {: prepare-level!} (require :source.lib.level)
   $ui (require :source.lib.ui)
   graph (require :source.lib.graph)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$]
    (let [
          tile-size 32
          grid-w (div level_0.w tile-size)
          grid-h (div level_0.h tile-size)
          locations {}

          {: stage-width : stage-height
           &as loaded} (prepare-level! level_0 entity-map {:floor   {:z-index -110}
                                                           :tree    { : locations : grid-w : grid-h}
                                                           :spawner { : locations : grid-w : grid-h}
                                                           :tiles   {:z-index -10}})
          wall-sprites (icollect [_ v (ipairs (playdate.graphics.sprite.getAllSprites))]
                         (if (?. v :wall?) v))

          graph (-> (graph.new-tile-graph grid-w grid-h { : tile-size : locations})
                    (: :remove-walls wall-sprites))
          ;; graph-locations (collect [k v (pairs locations)]
          ;;                   ;; (values k (graph:nodeWithXY (+ v.tile-x 1) (+ v.tile-y 1)))
          ;;                   (values k (graph:nodeWithID (+ (* grid-w v.tile-y) (+ v.tile-x 1))))
          ;;                   )
          player (?. (icollect [_ v (ipairs loaded.entities)]
                       (if (?. v :player?) v)) 1)
          ]
      (tset $ :state {: player : stage-width : stage-height : graph : grid-w})
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

  (fn debug-draw! [$]
    ;; ($.state.graph:draw)
    )
  )

