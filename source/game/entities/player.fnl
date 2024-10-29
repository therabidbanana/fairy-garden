(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   justpressed? playdate.buttonJustPressed
   gfx playdate.graphics
   $ui (require :source.lib.ui)
   tile (require :source.lib.behaviors.tile-movement)
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)
   splitter   (require :source.game.entities.splitter)
   sprinkler   (require :source.game.entities.sprinkler)
   redirect   (require :source.game.entities.redirect)
   happy   (require :source.game.entities.happy)
   ]

  (fn purchase-and-place! [{ :tile-movement-opts { : tile-w : tile-h } &as self} item]
    (let [ideal-x (* (div self.x tile-w) tile-w)
          ideal-y (* (div self.y tile-h) tile-h)]
      (case item
        {:type :redirect : dir} (-> (redirect.new! ideal-x ideal-y { :fields {: dir} : tile-w : tile-h }) (: :add))
        {:type :splitter : dir} (-> (splitter.new! ideal-x ideal-y { :fields {: dir} : tile-w : tile-h }) (: :add))
        {:type :sprinkler} (-> (sprinkler.new! ideal-x ideal-y {  : tile-w : tile-h }) (: :add))
        {:type :tulip} (-> (happy.new! ideal-x ideal-y {  : tile-w : tile-h }) (: :add))
        )
      )
    )

  (fn shop! [self]
    (self:->stop!)
    ($ui:open-menu! {:can-exit? true
                     :options [
                               {:text "Up" :action #(self:purchase-and-place! {:type :redirect :dir :up})}
                               {:text "Down" :action #(self:purchase-and-place! {:type :redirect :dir :down})}
                               {:text "Left" :action #(self:purchase-and-place! {:type :redirect :dir :left})}
                               {:text "Right" :action #(self:purchase-and-place! {:type :redirect :dir :right})}
                               {:text "Sprinkler" :action #(self:purchase-and-place! {:type :sprinkler})}
                               {:text "Tulip" :action #(self:purchase-and-place! {:type :tulip})}
                               {:text "Splitter L/R" :action #(self:purchase-and-place! {:type :splitter :dir :left})}
                               {:text "Splitter U/D" :action #(self:purchase-and-place! {:type :splitter :dir :up})}
                               ]})
    )

  (fn react! [{: state : height : x : y : width &as self} $scene]
    (if (justpressed? playdate.kButtonLeft) (self:->left!)
        (justpressed? playdate.kButtonRight) (self:->right!)
        (justpressed? playdate.kButtonUp) (self:->up!)
        (justpressed? playdate.kButtonDown) (self:->down!))
    (let [(dx dy) (self:tile-movement-react! state.speed)
          dx (if (and (>= (+ x width) $scene.state.stage-width) (> dx 0)) 0
                 (and (<= x 0) (< dx 0)) 0
                 dx)
          dy (if (and (>= (+ y height) $scene.state.stage-height) (> dy 0)) 0
                 (and (<= y 0) (< dy 0)) 0
                 dy)
          [facing-x facing-y] (case state.facing
                                :left [(- x 8) (+ y (div height 2))]
                                :right [(+ 40 x) (+ y (div height 2))]
                                :up [(+ x (div width 2)) (- y 8)]
                                _ [(+ x (div width 2)) (+ 8 height y)]) ;; 40 for height / width of sprite + 8
          [facing-sprite & _] (gfx.sprite.querySpritesAtPoint facing-x facing-y)
          clear-square true
          ]
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))

      (if (playdate.buttonJustPressed playdate.kButtonB)
          (scene-manager:select! :menu))
      (if (and (playdate.buttonJustPressed playdate.kButtonA)
               clear-square)
          (self:shop!))
      )
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

  (fn new! [x y {: tile-w : tile-h}]
    (let [image (gfx.imagetable.new :assets/images/player-sprite)
          animation (anim.new {: image :states [{:state :walking :start 1 :end 4}]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      (player:setCollideRect 6 1 18 30)
      (player:setGroups [1])
      (player:setCollidesWithGroups [ ])
      ;; (tset player :draw draw)
      (tset player :player? true)
      (tset player :update update)
      ;; (tset player :collisionResponse collisionResponse)
      (tset player :react! react!)
      (tset player :purchase-and-place! purchase-and-place!)
      (tset player :shop! shop!)
      (tset player :state {: animation :speed 6 :dx 0 :dy 0 :visible true})
      (tile.add! player {: tile-h : tile-w})
      player)))

