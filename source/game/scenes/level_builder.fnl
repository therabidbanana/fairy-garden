(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :level_builder
  [gfx playdate.graphics

   entity-map (require :source.game.entities.core)
   {: prepare-level!} (require :source.lib.level)
   libgraph (require :source.lib.graph)
   $ui (require :source.lib.ui)
   $particles (require :source.game.particles)
   ]

  (fn stage-tick! [{: state &as $scene}]
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

  (fn stage-draw! [$scene]
    ($particles:draw-all)
    ($ui:render!)
    )

  (fn build! [level]
    (let [tile-size 32
          grid-w (div level.w tile-size)
          grid-h (div level.h tile-size)
          locations {}

          {: stage-width : stage-height
           &as loaded} (prepare-level! level
                                       entity-map
                                       {:floor   {:z-index -110}
                                        :tree    { : locations : grid-w : grid-h :wave-details level.fields}
                                        :spawner { : locations : grid-w : grid-h :wave-details level.fields}
                                        :tiles   {:z-index -10}})
          wall-sprites (icollect [_ v (ipairs (playdate.graphics.sprite.getAllSprites))]
                         (if (?. v :wall?) v))

          graph (-> (libgraph.new-tile-graph grid-w grid-h { : tile-size : locations})
                    (: :remove-walls wall-sprites))
          player (?. (icollect [_ v (ipairs loaded.entities)]
                       (if (?. v :player?) v)) 1)
          tree (?. (icollect [_ v (ipairs loaded.entities)]
                     (if (?. v :tree?) v)) 1)
          spawner (?. (icollect [_ v (ipairs loaded.entities)]
                        (if (?. v :spawner?) v)) 1)
          tree-hud (-> (entity-map.tree-hud.new! tree) (: :add))
          hud (-> (entity-map.hud.new! player) (: :add))
          ]

      {: player : tree : spawner : stage-width : stage-height : graph : grid-w}
     )))
