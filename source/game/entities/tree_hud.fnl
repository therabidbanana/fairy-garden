(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :hud
  [gfx playdate.graphics
   $ui (require :source.lib.ui)]

  (fn react! [{:state { : tree  &as state} &as self}]
    (when (not= tree.state.accepted-fairies state.accepted-fairies)
      (tset state :accepted-fairies tree.state.accepted-fairies)
      (tset state :total-fairies tree.state.total-fairies)
      (tset state :dirty true))
    )

  (fn draw [self]
    (gfx.setColor gfx.kColorWhite)
    (let [mode (playdate.graphics.getImageDrawMode)]
      (playdate.graphics.setImageDrawMode "fillWhite")
      (self.tagFont:drawText (.. (string.format "%02d" (or self.state.accepted-fairies 0)) " of "
                                 (string.format "%02d" (or self.state.total-fairies 99))
                                 )
                             0 2
                             )
      ;; (gfx.setColor gfx.kColorWhite)
      ;; (gfx.fillRoundRect 6 14 24 14 2)
      ;; (gfx.setLineWidth 1)
      ;; (gfx.setColor gfx.kColorBlack)
      ;; (gfx.drawRoundRect 6 14 24 14 2)
      ;; (playdate.graphics.setImageDrawMode "fillBlack")
      ;; (self.tagFont:drawText (.. "x" (string.format "%d" self.state.speed))
      ;;                        8 16
      ;;                        )
      (playdate.graphics.setImageDrawMode mode)
      )
    

    )

  (fn update [{:state {: animation : dx : dy : walking? &as state} &as self}]
    (when self.state.dirty
      (tset self.state :dirty nil)
      (self:markDirty)
      )
    )

  (fn new! [tree]
    (let [hud (gfx.sprite.new)]
      (hud:setCenter 0 0)
      (hud:setSize 50 60)
      (hud:moveTo 340 0)
      (hud:setZIndex 1001)
      (hud:setIgnoresDrawOffset true)
      (tset hud :tagFont (gfx.font.new :assets/fonts/Nontendo-Bold))
      (tset hud :state {: tree :minutes 0 :speed 1})
      (tset hud :draw draw)
      (tset hud :update update)
      (tset hud :react! react!)
      hud))
  )
