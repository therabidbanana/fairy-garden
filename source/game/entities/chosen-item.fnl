(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :chosen-item
  [gfx playdate.graphics
   $ui (require :source.lib.ui)]

  (fn react! [{:state { : player &as state} &as self}]
    (let [chosen-item (or (?. player :state :chosen-item) nil)]
      (when (not= chosen-item state.chosen-item)
        (tset state :chosen-item chosen-item)
        (tset state :dirty true)
        )
      ;; (when (not= player-held state.player-held)
      ;;   (tset state :player-held player-held)
      ;;   (tset state :dirty true)
      ;;   )
      )
    self)

  (fn draw [self]
    (let [rect (playdate.geometry.rect.new 0 0
                                           240 20)]
      (when self.state.chosen-item
        (gfx.setColor gfx.kColorWhite)
        (gfx.fillRoundRect rect 4)
        (gfx.setLineWidth 2)
        (gfx.setColor gfx.kColorBlack)
        (gfx.drawRoundRect rect 4)
        (gfx.setColor gfx.kColorBlack)
        (self.tagFont:drawText (.. "Place " self.state.chosen-item.type) ;;(rect:insetBy 6 2)
                          6 2
                          ))
      )

    )

  (fn update [{:state {: animation : dx : dy : walking? &as state} &as self}]
    (when self.state.dirty
      (tset self.state :dirty nil)
      (self:markDirty)
      )
    )
  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   ;; (love.graphics.rectangle "fill" x y w h)
  ;;   (animation:draw x y)
  ;;   )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))
  (fn new! [player]
    (let [hud (gfx.sprite.new)]
      (hud:moveTo 80 210)
      (hud:setSize 240 100)
      (hud:setCenter 0 0)
      (hud:setZIndex 1000)
      (hud:setIgnoresDrawOffset true)
      (tset hud :tagFont (gfx.font.new :assets/fonts/Nontendo-Bold))
      (tset hud :state {: player})
      (tset hud :draw draw)
      (tset hud :update update)
      (tset hud :react! react!)
      hud))
  )
