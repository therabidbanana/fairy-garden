(import-macros {: pd/import : defns : inspect : div : clamp} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_0
  [{: prepare-level!} (require :source.lib.level)
   entity-map (require :source.game.entities.core)
   pd playdate
   scene-manager (require :source.lib.scene-manager)
   $ui (require :source.lib.ui)
   $particles (require :source.game.particles)
   gfx pd.graphics
   pressed? playdate.buttonIsPressed
   justpressed? playdate.buttonJustPressed
   ]

  (fn enter! [$ game-state]
    (let [menu (playdate.getSystemMenu)]
      (each [i v (ipairs (menu:getMenuItems))]
        (menu:removeMenuItem v)))
    (let [levels {}
          {: stage-width : stage-height
           &as loaded} (prepare-level! level_0
                                       entity-map
                                       {:floor   {:z-index -110}
                                        :warp    { : levels : grid-w : grid-h : game-state }
                                        :tiles   {:z-index -10}})
          selected-level (or (?. game-state :selected) :level_1)
          warp (?. levels selected-level)
          selector (entity-map.map-selector.new! warp.x warp.y)
          star-image (gfx.imagetable.new :assets/images/stars)
          ]
      (selector:add)
      (tset $ :state {: levels
                      : star-image
                      :selected selected-level : selector : stage-height : stage-width}))
    )

  (fn exit! [{: state &as $scene} game-state]
    (tset game-state :selected state.selected))

  (fn draw! [{:state { : star-image &as state} &as $scene} game-state]
    (let [level-state (?. game-state state.selected)
          warp (?. state.levels state.selected)
          stars (or (?. level-state :stars) 0)
          star-frame (clamp 1 (+ stars 1) 4)
          star-rect (playdate.geometry.rect.new 280 20 120 20)
          level-rect (playdate.geometry.rect.new 80 210 240 20)
          ]
      (playdate.graphics.pushContext)
      (playdate.graphics.setDrawOffset 0 0)
      ;; (gfx.setColor gfx.kColorWhite)
      ;; (gfx.fillRoundRect star-rect 4)
      ;; (gfx.setLineWidth 2)
      ;; (gfx.setColor gfx.kColorBlack)
      ;; (gfx.drawRoundRect star-rect 4)
      ;; (gfx.setColor gfx.kColorBlack)
      (: (star-image:getImage star-frame) :draw 320 10)
      ;; (gfx.drawText (if (> stars 0) (.. "Stars: " level-state.stars)
      ;;                   (.. "No Stars")) 286 22)

      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect level-rect 4)
      (gfx.setLineWidth 2)
      (gfx.setColor gfx.kColorBlack)
      (gfx.drawRoundRect level-rect 4)
      (gfx.setColor gfx.kColorBlack)
      (gfx.drawText (or warp.state.title state.selected) 86 212)

      (playdate.graphics.popContext)
      )
    ($particles:draw-all)
    ($ui:render!))

  ;; TODO: Fixme
  (local levels [:level_1 :level_5 :level_4 :level_2 :level_3 :level_6])
  (fn ->forward! [{: state &as $scene} game-state]
    (let [curr (or (?. (icollect [i v (ipairs levels)] (if (= v state.selected) i)) 1) 1)
          new-key (or (?. levels (+ curr 1)) (?. levels 1))
          new-warp (?. state.levels new-key)]
      (tset state :selected new-key)
      (state.selector:moveTo new-warp.x new-warp.y))
    )

  (fn ->backward! [{: state &as $scene} game-state]
    (let [curr (or (?. (icollect [i v (ipairs levels)] (if (= v state.selected) i)) 1) 1)
          new-key (or (?. levels (- curr 1)) (?. levels (length levels)))
          new-warp (?. state.levels new-key)]
      (tset state :selected new-key)
      (state.selector:moveTo new-warp.x new-warp.y))
    )

  (fn tick! [{: state &as $scene} game-state]
    (let [warp (?. state.levels state.selected)
          unlock-state (?. game-state warp.state.unlock)
          unlock-stars (or (?. unlock-state :stars) 0)
          unlocked? (or (= nil warp.state.unlock)
                        (>= unlock-stars 1))]
      (if ($ui:active?) ($ui:tick!) ;; tick if open
         (do
           (if (justpressed? playdate.kButtonLeft) (->backward! $scene game-state)
               (justpressed? playdate.kButtonRight) (->forward! $scene game-state)
               (justpressed? playdate.kButtonUp) (->backward! $scene game-state)
               (justpressed? playdate.kButtonDown) (->forward! $scene game-state)
               (and (justpressed? playdate.kButtonA) unlocked?)
               (scene-manager:select! state.selected)
               )
           (let [player-x state.selector.x
                 player-y state.selector.y
                 center-x (clamp 0 (- player-x 200) (- state.stage-width 400))
                 center-y (clamp 0 (- player-y 120) (- state.stage-height 240))]
             ;; (gfx.sprite.performOnAllSprites (fn react-each [ent] (if (?. ent :react!) (ent:react! $scene game-state))))
             (gfx.setDrawOffset (- 0 center-x) (- 0 center-y))
             ))
         ))
    )
  )

