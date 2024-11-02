(import-macros {: inspect : defns} :source.lib.macros)

(defns scene
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})
  (fn enter! [$ game-state]
    (let [menu (playdate.getSystemMenu)]
      (each [i v (ipairs (menu:getMenuItems))]
        (menu:removeMenuItem v)))
    (playdate.graphics.setDrawOffset 0 0)
    ($ui:open-menu! {:on-draw (fn [comp selected]
                                (gfx.clear)
                                (when selected.id
                                  (let [level-state (?. game-state selected.id)
                                        dayrect (playdate.geometry.rect.new 280 20 120 20)
                                        ]
                                    (gfx.setColor gfx.kColorWhite)
                                    (gfx.fillRoundRect dayrect 4)
                                    (gfx.setLineWidth 2)
                                    (gfx.setColor gfx.kColorBlack)
                                    (gfx.drawRoundRect dayrect 4)
                                    (gfx.setColor gfx.kColorBlack)
                                    (gfx.drawText (if (?. level-state :stars) (.. "Stars: " level-state.stars)
                                                      (.. "No Stars")) 286 22)
                                    ))
                                )
                     :options [
                               {:text "Level 1" :id :level_1 :action #(scene-manager:select! :level_1)}
                               {:text "Level 2" :id :level_2 :action #(scene-manager:select! :level_2)}
                               {:text "Level 3" :id :level_3 :action #(scene-manager:select! :level_3)}
                               ]})
    ;; (tset $ :state :listview (testScroll pd gfx))
    )

  (fn exit! [$]
    (tset $ :state {}))

  (fn tick! [{:state {: listview} &as $}]
    ;; (listview:drawInRect 180 20 200 200)
    (if ($ui:active?) ($ui:tick!)
        (let [pressed? playdate.buttonJustPressed]
          (if (pressed? playdate.kButtonA) (scene-manager:select! :level_0)))
        ))

  (fn draw! [{:state {: listview} &as $}]
    ($ui:render!)
    ;; (listview:drawInRect 180 20 200 200)
    )
  )

