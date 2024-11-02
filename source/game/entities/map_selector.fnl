(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   justpressed? playdate.buttonJustPressed
   gfx playdate.graphics
   $ui (require :source.lib.ui)
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)
   splitter   (require :source.game.entities.splitter)
   sprinkler   (require :source.game.entities.sprinkler)
   redirect   (require :source.game.entities.redirect)
   happy   (require :source.game.entities.happy)
   $particles           (require :source.game.particles)
   ]

  (fn react! [{: state : height : x : y : width &as self} $scene game-state]
    ;; (let [(dx dy) (self:tile-movement-react! state.speed)
    ;;       dx (if (and (>= (+ x width) $scene.state.stage-width) (> dx 0)) 0
    ;;              (and (<= x 0) (< dx 0)) 0
    ;;              dx)
    ;;       dy (if (and (>= (+ y height) $scene.state.stage-height) (> dy 0)) 0
    ;;              (and (<= y 0) (< dy 0)) 0
    ;;              dy)
    ;;       sprites-at (gfx.sprite.querySpritesAtPoint (+ x 1) (+ y 1))
    ;;       overlapping (?. (icollect [i v (ipairs sprites-at)]
    ;;                         (if (?. v :player?) nil v))
    ;;                       1)
    ;;       clear-square (= nil overlapping)
    ;;       ]
    ;;   (tset self :state :dx dx)
    ;;   (tset self :state :dy dy)
    ;;   (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))

    ;;   ;; (if (playdate.buttonJustPressed playdate.kButtonB)
    ;;   ;;     (scene-manager:select! :menu))
    ;;   (if (and (playdate.buttonJustPressed playdate.kButtonB)
    ;;            (?. overlapping :water!))
    ;;       (do
    ;;         ($particles.splash! self.x self.y)
    ;;         (overlapping:water! 1)))
    ;;   (if (and (playdate.buttonJustPressed playdate.kButtonA)
    ;;            (?. overlapping :player-interact!))
    ;;       (overlapping:player-interact! true)
    ;;       (and (playdate.buttonJustPressed playdate.kButtonA)
    ;;            clear-square)
    ;;       (self:shop!))
    ;;   )
    self)

  (fn update [{:state {: animation : dx : dy : walking?} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (self:setImage (animation:getImage))
      (self:markDirty))
    )

  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   ;; (love.graphics.rectangle "fill" x y w h)
  ;;   (animation:draw x y)
  ;;   )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y]
    (let [image (gfx.imagetable.new :assets/images/player-sprite)
          animation (anim.new {: image :states [{:state :walking :start 1 :end 4}]})
          player (gfx.sprite.new)
          cash  (or (?. fields cash) 10)
          ]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      (player:setCollideRect 0 0 32 32)
      (player:setGroups [1])
      (player:setCollidesWithGroups [])
      (player:setZIndex 12)
      ;; (tset player :draw draw)
      (tset player :player? true)
      (tset player :update update)
      ;; (tset player :collisionResponse collisionResponse)
      (tset player :react! react!)
      (tset player :state {: cash : animation :speed 6 :dx 0 :dy 0 :visible true})
      ;; (tile.add! player {: tile-h : tile-w})
      player)))

